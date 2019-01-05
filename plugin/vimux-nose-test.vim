" Backwards compatibility

" for python
command! RunNoseTest :call RunNoseTest("")
command! RunNoseTestWithCoverage :call RunNoseTest("coverage")
command! RunNoseTestFocused :call RunNoseTestFocused("")
command! RunNoseTestFocusedWithCoverage :call RunNoseTestFocused("coverage")
command! RunPythonFile :call RunPythonFile()

" for go
command! RunGoFile :call RunGoFile()
command! GoBuildAndRunFile :call GoBuildAndRunFile()

" python part
function! RunNoseTestFocused(coverage)
  let test_class = _nose_test_search("class ")
  let test_name = _nose_test_search("def test_")

  if test_class == "" || test_name == ""
    echoerr "Couldn't find class and test name to run focused test."
    return
  endif

  if a:coverage == "coverage"
      " https://nose.readthedocs.io/en/latest/plugins/cover.html
      let target = _nose_test_search_after_colon("coverage:")
      call _run_nosetests("-s --nologcapture --cover-erase --with-coverage --cover-package " . target . " ". expand("%") . ":" . test_class . "." . test_name)
  else
      call _run_nosetests("-s --nologcapture " . expand("%") . ":" . test_class . "." . test_name)
  endif
endfunction

function! RunNoseTest(coverage)
  if a:coverage == "coverage"
      let target = _nose_test_search_after_colon("coverage:")
      " https://nose.readthedocs.io/en/latest/plugins/cover.html
      call _run_nosetests("-s --nologcapture --cover-erase --with-coverage --cover-package " . target . " ". expand("%"))
  else
      call _run_nosetests("-s --nologcapture " . expand("%"))
  endif
endfunction

function! RunPythonFile()
  call VimuxRunCommand(_virtualenv() . "python " . expand("%"))
endfunction

function! _nose_test_search_after_colon(fragment)
  let line_num = search(a:fragment, "bs")
  if line_num > 0
    ''  " what this is for?!
    return split(getline(line_num), ":")[1]
  else
    return ""
  endif
endfunction

function! _nose_test_search(fragment)
  let line_num = search(a:fragment, "bs")
  if line_num > 0
    ''  " what this is for?!
    return split(split(getline(line_num), " ")[1], "(")[0]
  else
    return ""
  endif
endfunction

function! _run_nosetests(test)
  call VimuxRunCommand(_virtualenv() . "nosetests " . a:test)
endfunction

function! _virtualenv()
  if exists("g:NoseVirtualenv")
    return g:NoseVirtualenv . " "
  else
    return ""
  end
endfunction


" go part
function! GoBuildAndRunFile()
  call VimuxRunCommand(_virtualenv() . "go build; ./" . expand("%:p:h:t"))
endfunction

function! RunGoFile()
  call VimuxRunCommand(_virtualenv() . "go run " . expand("%"))
endfunction
