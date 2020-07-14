"""Code generator for Code Completion Model Inference.

Tool runs on the Decision Forest model defined in {model} directory.
It generates two files: {output_dir}/{filename}.h and {output_dir}/{filename}.cpp 
The generated files defines the Example class named {cpp_class} having all the features as class members.
The generated runtime provides an `Evaluate` function which can be used to score a code completion candidate.
"""

import argparse
import json
import struct
from enum import Enum


class CppClass:
    """Holds class name and names of the enclosing namespaces."""

    def __init__(self, cpp_class):
        ns_and_class = cpp_class.split("::")
        self.ns = [ns for ns in ns_and_class[0:-1] if len(ns) > 0]
        self.name = ns_and_class[-1]
        if len(self.name) == 0:
            raise ValueError("Empty class name.")

    def ns_begin(self):
        """Returns snippet for opening namespace declarations."""
        open_ns = [f"namespace {ns} {{" for ns in self.ns]
        return "\n".join(open_ns)

    def ns_end(self):
        """Returns snippet for closing namespace declarations."""
        close_ns = [
            f"}} // namespace {ns}" for ns in reversed(self.ns)]
        return "\n".join(close_ns)


def header_guard(filename):
    '''Returns the header guard for the generated header.'''
    return f"GENERATED_DECISION_FOREST_MODEL_{filename.upper()}_H"


def boost_node(n, label, next_label):
    """Returns code snippet for a leaf/boost node.
    Adds value of leaf to the score and jumps to the root of the next tree."""
    return f"{label}: Score += {n['score']}; goto {next_label};"


def if_greater_node(n, label, next_label):
    """Returns code snippet for a if_greater node.
    Jumps to true_label if the Example feature (NUMBER) is greater than the threshold. 
    Comparing integers is much faster than comparing floats. Assuming floating points 
    are represented as IEEE 754, it order-encodes the floats to integers before comparing them.
    Control falls through if condition is evaluated to false."""
    threshold = n["threshold"]
    return f"{label}: if (E.{n['feature']} >= {order_encode(threshold)} /*{threshold}*/) goto {next_label};"


def if_member_node(n, label, next_label):
    """Returns code snippet for a if_member node.
    Jumps to true_label if the Example feature (ENUM) is present in the set of enum values 
    described in the node.
    Control falls through if condition is evaluated to false."""
    members = '|'.join([
        f"BIT({n['feature']}_type::{member})"
        for member in n["set"]
    ])
    return f"{label}: if (E.{n['feature']} & ({members})) goto {next_label};"


def node(n, label, next_label):
    """Returns code snippet for the node."""
    return {
        'boost': boost_node,
        'if_greater': if_greater_node,
        'if_member': if_member_node,
    }[n['operation']](n, label, next_label)


def tree(t, tree_num: int, node_num: int):
    """Returns code for inferencing a Decision Tree.
    Also returns the size of the decision tree.

    A tree starts with its label `t{tree#}`.
    A node of the tree starts with label `t{tree#}_n{node#}`.

    The tree contains two types of node: Conditional node and Leaf node.
    -   Conditional node evaluates a condition. If true, it jumps to the true node/child.
        Code is generated using pre-order traversal of the tree considering
        false node as the first child. Therefore the false node is always the
        immediately next label.
    -   Leaf node adds the value to the score and jumps to the next tree.
    """
    label = f"t{tree_num}_n{node_num}"
    code = []
    if node_num == 0:
        code.append(f"t{tree_num}:")

    if t["operation"] == "boost":
        code.append(node(t, label=label, next_label=f"t{tree_num+1}"))
        return code, 1

    false_code, false_size = tree(
        t['else'], tree_num=tree_num, node_num=node_num+1)

    true_node_num = node_num+false_size+1
    true_label = f"t{tree_num}_n{true_node_num}"

    true_code, true_size = tree(
        t['then'], tree_num=tree_num, node_num=true_node_num)

    code.append(node(t, label=label, next_label=true_label))

    return code+false_code+true_code, 1+false_size+true_size


def gen_header_code(features_json: list, cpp_class, filename: str):
    """Returns code for header declaring the inference runtime.

    Declares the Example class named {cpp_class} inside relevant namespaces.
    The Example class contains all the features as class members. This 
    class can be used to represent a code completion candidate.
    Provides `float Evaluate()` function which can be used to score the Example.
    """
    setters = []
    for f in features_json:
        feature = f["name"]
        if f["kind"] == "NUMBER":
            # Floats are order-encoded to integers for faster comparison.
            setters.append(
                f"void set{feature}(float V) {{ {feature} = OrderEncode(V); }}")
        elif f["kind"] == "ENUM":
            setters.append(
                f"void set{feature}(unsigned V) {{ {feature} = 1 << V; }}")
        else:
            raise ValueError("Unhandled feature type.", f["kind"])

    # Class members represent all the features of the Example.
    class_members = [f"uint32_t {f['name']} = 0;" for f in features_json]

    nline = "\n  "
    guard = header_guard(filename)
    return f"""#ifndef {guard}
#define {guard}
#include <cstdint>

{cpp_class.ns_begin()}
class {cpp_class.name} {{
public:
  {nline.join(setters)}

private:
  {nline.join(class_members)}

  // Produces an integer that sorts in the same order as F.
  // That is: a < b <==> orderEncode(a) < orderEncode(b).
  static uint32_t OrderEncode(float F);
  friend float Evaluate(const {cpp_class.name}&);
}};

float Evaluate(const {cpp_class.name}&);
{cpp_class.ns_end()}
#endif // {guard}
"""


def order_encode(v: float):
    i = struct.unpack('<I', struct.pack('<f', v))[0]
    TopBit = 1 << 31
    # IEEE 754 floats compare like sign-magnitude integers.
    if (i & TopBit):  # Negative float
        return (1 << 32) - i  # low half of integers, order reversed.
    return TopBit + i  # top half of integers


def evaluate_func(forest_json: list, cpp_class: CppClass):
    """Generates code for `float Evaluate(const {Example}&)` function.
    The generated function can be used to score an Example."""
    code = f"float Evaluate(const {cpp_class.name}& E) {{\n"
    lines = []
    lines.append("float Score = 0;")
    tree_num = 0
    for tree_json in forest_json:
        lines.extend(tree(tree_json, tree_num=tree_num, node_num=0)[0])
        lines.append("")
        tree_num += 1

    lines.append(f"t{len(forest_json)}: // No such tree.")
    lines.append("return Score;")
    code += "  " + "\n  ".join(lines)
    code += "\n}"
    return code


def gen_cpp_code(forest_json: list, features_json: list, filename: str,
                 cpp_class: CppClass):
    """Generates code for the .cpp file."""
    # Headers
    # Required by OrderEncode(float F).
    angled_include = [
        f'#include <{h}>'
        for h in ["cstring", "limits"]
    ]

    # Include generated header.
    qouted_headers = {f"{filename}.h", "llvm/ADT/bit.h"}
    # Headers required by ENUM features used by the model.
    qouted_headers |= {f["header"]
                       for f in features_json if f["kind"] == "ENUM"}
    quoted_include = [f'#include "{h}"' for h in sorted(qouted_headers)]

    # using-decl for ENUM features.
    using_decls = "\n".join(f"using {feature['name']}_type = {feature['type']};"
                            for feature in features_json
                            if feature["kind"] == "ENUM")
    nl = "\n"
    return f"""{nl.join(angled_include)}

{nl.join(quoted_include)}

#define BIT(X) (1 << X)

{cpp_class.ns_begin()}

{using_decls}

uint32_t {cpp_class.name}::OrderEncode(float F) {{
  static_assert(std::numeric_limits<float>::is_iec559, "");
  constexpr uint32_t TopBit = ~(~uint32_t{{0}} >> 1);

  // Get the bits of the float. Endianness is the same as for integers.
  uint32_t U = llvm::bit_cast<uint32_t>(F);
  std::memcpy(&U, &F, sizeof(U));
  // IEEE 754 floats compare like sign-magnitude integers.
  if (U & TopBit)    // Negative float.
    return 0 - U;    // Map onto the low half of integers, order reversed.
  return U + TopBit; // Positive floats map onto the high half of integers.
}}

{evaluate_func(forest_json, cpp_class)}
{cpp_class.ns_end()}
"""


def main():
    parser = argparse.ArgumentParser('DecisionForestCodegen')
    parser.add_argument('--filename', help='output file name.')
    parser.add_argument('--output_dir', help='output directory.')
    parser.add_argument('--model', help='path to model directory.')
    parser.add_argument(
        '--cpp_class',
        help='The name of the class (which may be a namespace-qualified) created in generated header.'
    )
    ns = parser.parse_args()

    output_dir = ns.output_dir
    filename = ns.filename
    header_file = f"{output_dir}/{filename}.h"
    cpp_file = f"{output_dir}/{filename}.cpp"
    cpp_class = CppClass(cpp_class=ns.cpp_class)

    model_file = f"{ns.model}/forest.json"
    features_file = f"{ns.model}/features.json"

    with open(features_file) as f:
        features_json = json.load(f)

    with open(model_file) as m:
        forest_json = json.load(m)

    with open(cpp_file, 'w+t') as output_cc:
        output_cc.write(
            gen_cpp_code(forest_json=forest_json,
                         features_json=features_json,
                         filename=filename,
                         cpp_class=cpp_class))

    with open(header_file, 'w+t') as output_h:
        output_h.write(gen_header_code(
            features_json=features_json, cpp_class=cpp_class, filename=filename))


if __name__ == '__main__':
    main()
