module m1
  interface
    module subroutine s()
    end subroutine
  end interface
end

module m2
  interface
    module subroutine s()
    end subroutine
  end interface
end

submodule(m1) s1
end

!ERROR: Cannot find module file for submodule 's1' of module 'm2'
submodule(m2:s1) s2
end

!ERROR: Cannot find module file for 'm3'
submodule(m3:s1) s3
end
