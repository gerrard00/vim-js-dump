" TODO: if there is no visual selection we should just viw
" TODO: allow undo of last added dump
" TODO: allow undo of all added dumps
"
 " Only do this when not done yet for this buffer
 " if exists('g:loaded_js_dump')
 "   finish
 " endif
 " let g:loaded_js_dump = 1

" https://vi.stackexchange.com/q/7149/5862
function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

function! s:find_semicolon()
  let currentLineNumber = line('.')
  let lastLineNumber = line('$')
  let foundLineNumber = -1

  while (foundLineNumber == -1) && (currentLineNumber <= lastLineNumber)
    let currentLineText = getline(currentLineNumber)

    if (currentLineText =~ ';$')
      let foundLineNumber = currentLineNumber
    else
      let currentLineNumber += 1
    endif
  endwhile

  " TODO: does this make sense? if we didn't find it use the last line?
  if (foundLineNumber == -1)
    let foundLineNumber = lastLineNumber
  endif

  return foundLineNumber
endfunction

function! s:dumpSelection() range
  echo 'range = ' . a:firstline . ',' . a:lastline
  let expressionToDump = s:get_visual_selection()
  let expressionToDisplay = strpart(expressionToDump, 0, 20)

  let lineBeforeAppend = s:find_semicolon()

  call append(lineBeforeAppend, [
        \ '',
        \ 'console.log(''***************<dump| ' . expressionToDisplay . '***************'');',
        \ 'console.log(JSON.stringify(' . expressionToDump . '));',
        \ 'console.log(''***************|dump> ' . expressionToDisplay . '***************'');',
        \ ''
        \])
endfunction

command! -range JSDump :call s:dumpSelection()
" this should be localleader
vnoremap <Leader>du :JSDump<CR>
