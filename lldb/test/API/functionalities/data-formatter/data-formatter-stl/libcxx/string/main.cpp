#include <string>
#include <stdint.h>

// For more information about libc++'s std::string ABI, see:
//
//   https://joellaity.com/2020/01/31/string.html

// A corrupt string which hits the SSO code path, but has an invalid size.
static struct {
  // Set the size of this short-mode string to 116. Note that in short mode,
  // the size is encoded as `size << 1`.
  unsigned char size = 232;

  // 23 garbage bytes for the inline string payload.
  char inline_buf[23] = {0};
} garbage_string_short_mode;

// A corrupt libcxx string in long mode with a payload that contains a utf8
// sequence that's inherently too long.
static unsigned char garbage_utf8_payload1[] = {
  250 // This means that we expect a 5-byte sequence, this is invalid.
};
static struct {
  uint64_t cap = 5;
  uint64_t size = 4;
  unsigned char *data = &garbage_utf8_payload1[0];
} garbage_string_long_mode1;

// A corrupt libcxx string in long mode with a payload that contains a utf8
// sequence that's too long to fit in the buffer.
static unsigned char garbage_utf8_payload2[] = {
  240 // This means that we expect a 4-byte sequence, but the buffer is too
      // small for this.
};
static struct {
  uint64_t cap = 3;
  uint64_t size = 2;
  unsigned char *data = &garbage_utf8_payload1[0];
} garbage_string_long_mode2;

// A corrupt libcxx string which has an invalid size (i.e. a size greater than
// the capacity of the string).
static struct {
  uint64_t cap = 5;
  uint64_t size = 7;
  const char *data = "foo";
} garbage_string_long_mode3;

// A corrupt libcxx string in long mode with a payload that would trigger a
// buffer overflow.
static struct {
  uint64_t cap = 5;
  uint64_t size = 2;
  uint64_t data = 0xfffffffffffffffeULL;
} garbage_string_long_mode4;

int main()
{
    std::wstring wempty(L"");
    std::wstring s(L"hello world! מזל טוב!");
    std::wstring S(L"!!!!");
    const wchar_t *mazeltov = L"מזל טוב";
    std::string empty("");
    std::string q("hello world");
    std::string Q("quite a long std::strin with lots of info inside it");
    std::string TheVeryLongOne("1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890someText1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890");
    std::string IHaveEmbeddedZeros("a\0b\0c\0d",7);
    std::wstring IHaveEmbeddedZerosToo(L"hello world!\0てざ ル゜䋨ミ㠧槊 きゅへ狦穤襩 じゃ馩リョ 䤦監", 38);
    std::u16string u16_string(u"ß水氶");
    std::u16string u16_empty(u"");
    std::u32string u32_string(U"🍄🍅🍆🍌");
    std::u32string u32_empty(U"");
    std::basic_string<unsigned char> uchar(5, 'a');

#if _LIBCPP_ABI_VERSION == 1
    std::string garbage1, garbage2, garbage3, garbage4, garbage5;
    if (sizeof(std::string) == sizeof(garbage_string_short_mode))
      memcpy((void *)&garbage1, &garbage_string_short_mode, sizeof(std::string));
    if (sizeof(std::string) == sizeof(garbage_string_long_mode1))
      memcpy((void *)&garbage2, &garbage_string_long_mode1, sizeof(std::string));
    if (sizeof(std::string) == sizeof(garbage_string_long_mode2))
      memcpy((void *)&garbage3, &garbage_string_long_mode2, sizeof(std::string));
    if (sizeof(std::string) == sizeof(garbage_string_long_mode3))
      memcpy((void *)&garbage4, &garbage_string_long_mode3, sizeof(std::string));
    if (sizeof(std::string) == sizeof(garbage_string_long_mode4))
      memcpy((void *)&garbage5, &garbage_string_long_mode4, sizeof(std::string));
#else
#error "Test potentially needs to be updated for a new std::string ABI."
#endif

    S.assign(L"!!!!!"); // Set break point at this line.
    return 0;
}
