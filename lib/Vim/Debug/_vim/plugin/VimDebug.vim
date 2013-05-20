" (c) eric johnson
" email: vimDebug at iijo dot org
" http://iijo.org

   " Check prerequisites.
if (!has('perl') || !has('signs'))
   echo "VimDebug requires +perl and +signs"
   finish
endif


" key bindings
map <unique> <F12>         :DBGRbeginDebugger<CR>
map <unique> <Leader><F12> :DBGRstart<SPACE>perl -Ilib -d <C-R>%
map <unique> <F6>          :DBGRstepout<CR>
map <unique> <F7>          :DBGRstep<CR>
map <unique> <F8>          :DBGRnext<CR>
map <unique> <F9>          :DBGRcont<CR>                   " continue
map <unique> <Leader>b     :DBGRsetBreakPoint<CR>
map <unique> <Leader>be    :exec 'tabedit ' . g:DBGRgeneralBreakPointsFile<CR>
map <unique> <Leader>v     :DBGRupdateVarView<CR>
map <unique> <Leader>s     :DBGRtoggleStackTraceView<CR>
map <unique> <Leader>f     :DBGRtoggleFoldingVarView<CR>
map <unique> <Leader>cab   :DBGRclearAllBreakPoints<CR>
map <unique> <Leader>x/    :DBGRprint<SPACE>
map <unique> <Leader>x     :DBGRprintExpand expand("<cWORD>")<CR> " value under cursor
map <unique> <Leader>/     :DBGRcommand<SPACE>
map <unique> <F10>         :DBGRrestart<CR>
map <unique> <F11>         :DBGRquit<CR>

" commands
command! -nargs=* DBGRstart                    call DBGRstart("<args>")
command! -nargs=0 DBGRbeginDebugger            call DBGRbeginDebugger()
command! -nargs=0 DBGRstepout                  call DBGRstepout()
command! -nargs=0 DBGRstep                     call DBGRstep()
command! -nargs=0 DBGRnext                     call DBGRnext()
command! -nargs=0 DBGRcont                     call DBGRcont()
command! -nargs=0 DBGRsetBreakPoint            call DBGRsetBreakPoint()
command! -nargs=0 DBGRupdateVarView            call DBGRupdateVarView()
command! -nargs=0 DBGRtoggleStackTraceView     call DBGRtoggleStackTraceView()
command! -nargs=0 DBGRtoggleFoldingVarView     call DBGRtoggleFoldingVarView()
command! -nargs=0 DBGRtoggleAutoUpdateVarsView call DBGRtoggleAutoUpdateVarsView()
command! -nargs=0 DBGRclearBreakPoint          call DBGRclearBreakPoint()
command! -nargs=0 DBGRclearAllBreakPoints      call DBGRclearAllBreakPoints()
command! -nargs=1 DBGRprintExpand              call DBGRprint(<args>)
command! -nargs=1 DBGRcommand                  call DBGRcommand("<args>")
command! -nargs=0 DBGRrestart                  call DBGRrestart()
command! -nargs=0 DBGRquit                     call DBGRquit()

" colors
hi currentLine term=reverse cterm=reverse gui=reverse
hi breakPoint  term=NONE    cterm=NONE    gui=NONE
hi empty       term=NONE    cterm=NONE    gui=NONE

" signs
sign define currentLine linehl=currentLine
sign define breakPoint  linehl=breakPoint  text=>>
sign define both        linehl=currentLine text=>>
sign define empty       linehl=empty

" global variables
if !exists("g:DBGRconsoleHeight")
   let g:DBGRconsoleHeight      = 7
endif
if !exists("g:DBGRstackTraceHeight")
    let g:DBGRstackTraceHeight      = 7
endif
if !exists("g:DBGRlineNumbers")
    let g:DBGRlineNumbers           = 1
endif
if !exists("g:DBGRshowConsole")
    let g:DBGRshowConsole           = 1
endif
if !exists("g:DBGRshowVarView")
   let g:DBGRshowVarView        = 1
endif 
if !exists("g:DBGRautoUpdateVarView")
    let g:DBGRautoUpdateVarView     = 1
endif 
if !exists("g:DBGRshowStackTraceView")
    let g:DBGRshowStackTraceView    = 1
endif 
if !exists("g:DBGRautoUpdateStackTraceView")
    let g:DBGRautoUpdateStackTraceView     = 1
endif 
if !exists("g:DBGRtoggleFoldingVarView")
    let g:DBGRtoggleFoldingVarView     = 1
endif 
if !exists("g:DBGRdebugArgs")
    let g:DBGRdebugArgs             = ""
endif 
if !exists("g:DBGRsavedBreakPointsDirectory")
    let g:DBGRsavedBreakPointsDirectory = $HOME . "/.vim/vimDBGR"
endif 
if !exists("g:DBGRgeneralBreakPointsFile")
    let g:DBGRgeneralBreakPointsFile = g:DBGRsavedBreakPointsDirectory . "/.generalBreakPoints"
endif 

let s:initialDebuggedFileName = ""


perl $DBGRsocket1               = 0;
perl $DBGRsocket2               = 0;

" menu items
amenu &Debugger.Start\        :call DBGRbeginDebugger()<CR> 
amenu &Debugger.Next\         :call DBGRnext()<CR> 
amenu &Debugger.Step\         :call DBGRstep()<CR> 
amenu &Debugger.StepOut\      :call DBGRstepout()<CR> 
amenu &Debugger.Continue\     :call DBGRcont()<CR> 
amenu &Debugger.ToggleStackTrace\   :call DBGRtoggleStackTraceView()<CR> 
amenu &Debugger.FoldingVariables\   :call DBGRtoggleFoldingVarView()<CR> 
amenu &Debugger.Restart\      :call DBGRrestart()<CR> 
amenu &Debugger.Quit\         :call DBGRquit()<CR> 

amenu ToolBar.-debuggerSep1-  :
amenu ToolBar.DBGRbug         :call DBGRbeginDebugger()<CR>
tmenu ToolBar.DBGRbug Start perl debugging session

" script constants
let s:EOR_REGEX       = '-vimdebug.eor-'   " End Of Record Regular Expression
let s:EOM             = "\r\nvimdebug.eom\r\n"       " End Of Message
let s:EOM_LEN         = len(s:EOM)
let s:COMPILER_ERROR  = "compiler error"     " not in use yet
let s:RUNTIME_ERROR   = "runtime error"      " not in use yet
let s:APP_EXITED      = "application exited" " not in use yet
let s:DBGR_READY      = "debugger ready"      
let s:CONNECT         = "CONNECT"
let s:DISCONNECT      = "DISCONNECT"

let s:PORT            = 6543
let s:HOST            = "localhost"
let s:DONE_FILE       = ".vdd.done"

" script variables
let s:incantation     = ""
let s:dbgrIsRunning   = 0    " 0: !running, 1: running, 2: starting
let s:debugger        = "Perl"
let s:lineNumber      = 0
let s:fileName        = ""
let s:bufNr           = 0
let s:programDone     = 0
let s:consoleBufNr    = -99
let s:emptySigns      = []
let s:breakPoints     = []
let s:return          = 0
let s:sessionId       = -1
let s:breakPointItems = []


" debugger functions
function! DBGRbeginDebugger()
   " if they are using a GUI then get the arguments to the debugging session
   " with a graphic dialog box
   if has("gui")
      let g:DBGRdebugArgs = inputdialog("Enter arguments for debugging", g:DBGRdebugArgs)
   else 
      " otherwise use the command input
      call inputsave()
      let g:DBGRdebugArgs = input("Enter arguments for debugging: ", g:DBGRdebugArgs)
      call inputrestore()
   endif
   " call the debugger with arguments 
   call DBGRstart(g:DBGRdebugArgs)
endfunction
function! DBGRstart(...)
   if s:dbgrIsRunning
      echo "\rthe debugger is already running"
      return
   endif
   try
      let s:dbgrIsRunning = 2
      call s:Incantation()
      let s:initialDebuggedFileName = bufname("%")
      call s:StartVdd()
      " do after system() so nongui vim doesn't show a blank screen
      echo "\rstarting the debugger..."
      call s:SocketConnect()
      if has("autocmd")
         autocmd VimLeave * call DBGRquit()
      endif

      " set up the toolbar buttons
      if has("gui")
         aunmenu ToolBar.DBGRbug
         amenu ToolBar.DBGRstepout       :call DBGRstepout()<CR> 
         tmenu ToolBar.DBGRstepout Step out of subroutine
         amenu ToolBar.DBGRstepinto      :call DBGRstep()<CR> 
         tmenu ToolBar.DBGRstepinto Step into subroutine
         amenu ToolBar.DBGRnext          :call DBGRnext()<CR> 
         tmenu ToolBar.DBGRnext Next line
         amenu ToolBar.DBGRcontinue      :call DBGRcont()<CR> 
         tmenu ToolBar.DBGRcontinue Continue
         amenu ToolBar.-DBGRSep1-        :
         amenu ToolBar.DBGRquit          :call DBGRquit()<CR> 
         tmenu ToolBar.DBGRquit Quit debugging session
         amenu ToolBar.DBGRrestart       :call DBGRrestart()<CR> 
         tmenu ToolBar.DBGRrestart Restart debugging session
      endif

      call DBGRopenConsole()
      call DBGRopenStackTraceView()
      call DBGRopenVariablesView()
      redraw!
      call s:HandleCmdResult("connected to VimDebug daemon")
      call s:Handshake()
      call s:HandleCmdResult("started the debugger")
      call s:SocketConnect2()
      call s:HandleCmdResult2()
      let s:dbgrIsRunning = 1
      call DBGRloadBreakPoints()
   catch /AbortLaunch/
      echo "Launch aborted."
      let s:dbgrIsRunning = 0
   catch /UnknownFileType/
      let s:dbgrIsRunning = 0
      echo "There is no debugger associated with this file type."
   endtry
endfunction
function! DBGRnext()
   if !s:Copacetic()
      return
   endif
   echo "\rnext..."
   call s:SocketWrite("next")
   call s:HandleCmdResult()
endfunction
function! DBGRstep()
   if !s:Copacetic()
      return
   endif
   echo "\rstep..."
   call s:SocketWrite("step")
   call s:HandleCmdResult()
endfunction
function! DBGRstepout()
   if !s:Copacetic()
      return
   endif
   echo "\rstepout..."
   call s:SocketWrite("stepout")
   call s:HandleCmdResult()
endfunction
function! DBGRcont()
   if !s:Copacetic()
      return
   endif
   echo "\rcontinue..."
   call s:SocketWrite("cont")
   call s:HandleCmdResult()
endfunction
function! DBGRsetBreakPoint()
   if s:dbgrIsRunning != 1
      " the debugger isn't running but they want to set a break point 
      " so save the file and line number so that it will be set appropriately
      " when the debugger starts
      let l:currFileName = bufname("%")
      let l:currLineNr   = line(".")

      " create the name from the initial debugged file name 
      let l:breakPointsFile = g:DBGRsavedBreakPointsDirectory
      let l:breakPointItem = l:currFileName . ":" . l:currLineNr

      if filereadable(g:DBGRgeneralBreakPointsFile)
         let s:breakPointItems = readfile(g:DBGRgeneralBreakPointsFile)
         if count(s:breakPointItems, l:breakPointItem) == 1 
            return
         endif
      endif
      call add(s:breakPointItems, l:breakPointItem)
      " and save that file out
      call writefile(s:breakPointItems, g:DBGRgeneralBreakPointsFile)
      return
   endif

   let l:currFileName = bufname("%")
   let l:bufNr        = bufnr("%")
   let l:currLineNr   = line(".")
   let l:id           = s:CreateId(l:bufNr, l:currLineNr)

   if count(s:breakPoints, l:id) == 1
      redraw! | echo "\rbreakpoint already set"
      return
   endif

   " tell vdd
   call s:SocketWrite("break:" . l:currLineNr . ':' . l:currFileName)

   let l:breakPointItem = l:currFileName . ":" . l:currLineNr
   call add(s:breakPointItems, l:breakPointItem)
   call add(s:breakPoints, l:id)

   " check if a currentLine sign is already placed
   if (s:lineNumber == l:currLineNr)
      exe "sign unplace " . l:id
      exe "sign place " . l:id . " line=" . l:currLineNr . " name=both file=" . l:currFileName
   else
      exe "sign place " . l:id . " line=" . l:currLineNr . " name=breakPoint file=" . l:currFileName
   endif

   call s:HandleCmdResult("breakpoint set")
endfunction
function! DBGRsaveBreakPoints()
   call writefile(s:breakPointItems, g:DBGRgeneralBreakPointsFile)
endfunction
function! DBGRloadBreakPoints()
   " since we don't really have a buffer yet for these we need take the buffer
   " we are and create new buffer number.  One that probably won't be used.
   " Note that later when we are in the loop going through the saved
   " breakpoints that we will give each one a separate buffere number relative to
   " this one
   let l:bufNr        = bufnr("%") + 1000

   " get the general breakpoints file first
   if filereadable(g:DBGRgeneralBreakPointsFile)
      let s:breakPointItems = readfile(g:DBGRgeneralBreakPointsFile)
      for l:aLine in s:breakPointItems 
         let l:items = split(l:aLine, ":")
         " make sure the file exists before registering the breakpoint
         if filereadable(l:items[0])
            " add the break point to the list that is being tracked
            let l:bufNr = l:bufNr + 1
            let l:id           = s:CreateId(l:bufNr, l:items[1])
            if count(s:breakPoints, l:id) == 1
               continue
            endif
            call add(s:breakPoints, l:id)

            " tell vdd about the break point
            call s:SocketWrite("filelook:" . l:items[0])
            " call s:HandleCmdResult("file look")
            let l:cmdResult  = split(s:SocketRead(), s:EOR_REGEX, 1)
            call s:SocketWrite("breakline:" . l:items[1])
            "call s:HandleCmdResult("breakpoint set")
            let l:cmdResult  = split(s:SocketRead(), s:EOR_REGEX, 1)
         endif
      endfor
   endif
endfunction
function! DBGRclearBreakPoint()
   if !s:Copacetic()
      return
   endif

   let l:currFileName = bufname("%")
   let l:bufNr        = bufnr("%")
   let l:currLineNr   = line(".")
   let l:id           = s:CreateId(l:bufNr, l:currLineNr)

   let l:breakPointJoinedItem = l:currFileName . ':' . l:currLineNr
   if count(s:breakPointItems, l:breakPointJoinedItem) == 0
      if count(s:breakPoints, l:id) == 0 
         redraw! | echo "\rno breakpoint set here"
         return
      endif
   endif

   " tell vdd
   call s:SocketWrite("clear:" . l:currLineNr . ':' . l:currFileName)

   let l:indexInList = index(s:breakPointItems, l:breakPointJoinedItem)
   if l:indexInList >= 0 
      call remove(s:breakPointItems, l:indexInList)
   endif
   call filter(s:breakPoints, 'v:val != l:id')
   exe "sign unplace " . l:id

   if(s:lineNumber == l:currLineNr)
      exe "sign place " . l:id . " line=" . l:currLineNr . " name=currentLine file=" . l:currFileName
   endif

   call s:HandleCmdResult("breakpoint disabled")
endfunction
function! DBGRclearAllBreakPoints()
   if !s:Copacetic()
      return
   endif

   call s:UnplaceBreakPointSigns()

   let l:currFileName = bufname("%")
   let l:bufNr        = bufnr("%")
   let l:currLineNr   = line(".")
   let l:id           = s:CreateId(l:bufNr, l:currLineNr)

   call s:SocketWrite("clearAll")

   " do this in case the last current line had a break point on it
   call s:UnplaceTheLastCurrentLineSign()                " unplace the old sign
   call s:PlaceCurrentLineSign(s:lineNumber, s:fileName) " place the new sign

   call s:HandleCmdResult("all breakpoints disabled")
   let s:breakPointItems = []
endfunction
function! DBGRprint(...)
   if !s:Copacetic()
      return
   endif
   if a:0 > 0
      call s:SocketWrite("print:" . a:1)
      call s:HandleCmdResult()
   endif
endfunction
function! DBGRcommand(...)
   if !s:Copacetic()
      return
   endif
   echo ""
   if a:0 > 0
      call s:SocketWrite('command:' . a:1)
      call s:HandleCmdResult()
   endif
endfunction
function! DBGRrestart()
   if ! s:dbgrIsRunning
      echo "\rthe debugger is not running"
      return
   endif
   call s:SocketWrite("restart")
   " do after the system() call so that nongui vim doesn't show a blank screen
   echo "\rrestarting..."
   call s:UnplaceTheLastCurrentLineSign()
   redraw!
   call s:HandleCmdResult("restarted")
   let s:programDone = 0
endfunction
function! DBGRquit()
   if ! s:dbgrIsRunning
      echo "\rthe debugger is not running"
      return
   endif

   if has("gui")
      aunmenu ToolBar.DBGRstepout
      aunmenu ToolBar.DBGRstepinto
      aunmenu ToolBar.DBGRnext
      aunmenu ToolBar.DBGRcontinue
      aunmenu ToolBar.-DBGRSep1-
      aunmenu ToolBar.DBGRquit
      aunmenu ToolBar.DBGRrestart
      amenu ToolBar.DBGRbug    :call DBGRbeginDebugger()<CR>
      tmenu ToolBar.DBGRbug Start perl debugging session
   endif

   " unplace all signs that were set in this debugging session
   call s:UnplaceBreakPointSigns()
   call s:UnplaceEmptySigns()
   call s:UnplaceTheLastCurrentLineSign()
   call s:SetNoNumber()

   call s:SocketWrite("quit")

   if has("autocmd")
     autocmd! VimLeave * call DBGRquit()
   endif

   " reinitialize script variables
   let s:lineNumber      = 0
   let s:fileName        = ""
   let s:bufNr           = 0
   let s:programDone     = 0

   let s:dbgrIsRunning = 0
   redraw! | echo "\rexited the debugger"

   " must do this last
   call DBGRcloseVariablesView()
   call DBGRcloseStackTraceView()
   call DBGRcloseConsole()
   call DBGRsaveBreakPoints()
endfunction


" utility functions

" returns 1 if everything is copacetic
" returns 0 if things are not copacetic
function! s:Copacetic()
   if s:dbgrIsRunning != 1
      echo "\rthe debugger is not running"
      return 0
   elseif s:programDone
      echo "\rthe application being debugged terminated"
      return 0
   endif
   return 1
endfunction
function! s:PlaceEmptySign()
   let l:id = s:CreateId(bufnr("%"), "1")
   if count(s:emptySigns, l:id) == 0
      let l:fileName = bufname("%")
      call add(s:emptySigns, l:id)
      exe "sign place " . l:id . " line=1 name=empty file=" . l:fileName
   endif
endfunction
function! s:UnplaceEmptySigns()
   let l:oldBufNr = bufnr("%")
   for l:id in s:emptySigns
      let l:bufNr = s:BufNrFromId(l:id)
      if bufexists(l:bufNr) != 0
         if bufnr("%") != l:bufNr
            exe "buffer " . l:bufNr
         endif
         exe "sign unplace " . l:id
         exe "buffer " . l:oldBufNr
      endif
   endfor
   let s:emptySigns = []
endfunction
function! s:UnplaceBreakPointSigns()
   let l:oldBufNr = bufnr("%")
   for l:id in s:breakPoints
      let l:bufNr = s:BufNrFromId(l:id)
      if bufexists(l:bufNr) != 0
         if bufnr("%") != l:bufNr
            exe "buffer " . l:bufNr
         endif
         exe "sign unplace " . l:id
         exe "buffer " . l:oldBufNr
      endif
   endfor
   let s:breakPoints = []
endfunction
function! s:SetNumber()
   if g:DBGRlineNumbers == 1
      set number
   endif
endfunction
function! s:SetNoNumber()
   if g:DBGRlineNumbers == 1
      set nonumber
   endif
endfunction
function! s:CreateId(bufNr, lineNumber)
   return a:bufNr * 10000000 + a:lineNumber
endfunction
function! s:BufNrFromId(id)
   return a:id / 10000000
endfunction
function! s:LineNrFromId(id)
   return a:id % 10000000
endfunction

function! s:Incantation()
   try
      let s:bufNr       = bufnr("%")
      let s:fileName    = bufname("%")
      if s:fileName == ""
         throw "NoFileToDebug"
      endif
      let args = input("Enter arguments if any: ")
         " Some day, we may do more than just Perl.
      let s:incantation = "perl -Ilib -d " . s:fileName
      if args != ""
         let s:incantation .= " " . args
      endif
   catch /NoFileToDebug/
      echo "No file to debug."
      throw "AbortLaunch"
   catch
      throw "AbortLaunch"
   endtry
endfunction 

function! s:HandleCmdResult(...)
   let l:cmdResult  = split(s:SocketRead(), s:EOR_REGEX, 1)
   let [l:status, l:lineNumber, l:fileName, l:value, l:output] = l:cmdResult

   if l:status == s:DBGR_READY
      call s:ConsolePrint(l:output)
      if len(l:lineNumber) > 0
         call s:CurrentLineMagic(l:lineNumber, l:fileName)
      endif
      if g:DBGRautoUpdateVarView == 1
         call DBGRupdateVarView()
      endif
      if g:DBGRautoUpdateStackTraceView == 1
         call DBGRupdateStackTraceView()
      endif

   elseif l:status == s:APP_EXITED
      call s:ConsolePrint(l:output)
      call s:HandleProgramTermination()
      redraw! | echo "\rthe application being debugged terminated"

   elseif l:status == s:CONNECT
      let s:sessionId = l:value

   elseif l:status == s:DISCONNECT
      echo "disconnected"

   else
      echo "error:001.  something bad happened.  please report this to vimdebug at iijo dot org"
   endif

   return
endfunction
function! DBGRupdateVarView()
   if !s:Copacetic()
      return
   endif
   call s:SocketWrite("varView")
   let l:varViewResult  = split(s:SocketRead(), s:EOR_REGEX, 1)
   let [l:varStatus, l:varLineNumber, l:varFileName, l:varValue, l:varOutput] = l:varViewResult
   call s:VarViewPrint(l:varOutput)
endfunction
function! DBGRupdateStackTraceView()
   call s:SocketWrite("stackTrace")
   let l:varViewResult  = split(s:SocketRead(), s:EOR_REGEX, 1)
   let [l:varStatus, l:varLineNumber, l:varFileName, l:varValue, l:varOutput] = l:varViewResult
   call s:StackTraceViewPrint(l:varOutput)
endfunction
function! DBGRtoggleStackTraceView()
    if g:DBGRshowStackTraceView    == 1
      call DBGRcloseStackTraceView()
      let g:DBGRshowStackTraceView = 0
    else
      let g:DBGRshowStackTraceView = 1
      call DBGRupdateStackTraceView()
    endif
endfunction
function! DBGRtoggleAutoUpdateVarsView()
   if g:DBGRautoUpdateVarView == 1
      let g:DBGRautoUpdateVarView = 0
    else
      let g:DBGRautoUpdateVarView = 1
      call DBGRupdateVarView()
    endif
endfunction
function! DBGRtoggleFoldingVarView()
   let l:varViewWinNr = bufwinnr(s:varViewBufNr)
   if l:varViewWinNr == -1
      return
   endif
   exe l:varViewWinNr . "wincmd w"
   if g:DBGRtoggleFoldingVarView == 1
     let g:DBGRtoggleFoldingVarView = 0
     normal zR
   else
     let g:DBGRtoggleFoldingVarView = 1
     normal zM
   endif
   wincmd p
endfunction
" - jumps to the lineNumber in the file, fileName
" - highlights the current line
" - returns nothing
function! s:CurrentLineMagic(lineNumber, fileName)

   let l:lineNumber = a:lineNumber
   let l:fileName   = a:fileName
   let l:fileName   = s:JumpToLine(l:lineNumber, l:fileName)

   " if no signs placed in this file, place an invisible one on line 1.
   " otherwise, the code will shift left when the old currentline sign is
   " unplaced and then shift right again when the new currentline sign is
   " placed.  and thats really annoying for the user.
   call s:PlaceEmptySign()
   call s:UnplaceTheLastCurrentLineSign()                " unplace the old sign
   call s:PlaceCurrentLineSign(l:lineNumber, l:fileName) " place the new sign
   call s:SetNumber()
   "z. " scroll page so that this line is in the middle

   " set script variables for next time
   let s:lineNumber = l:lineNumber
   let s:fileName   = l:fileName

   return
endfunction
" the fileName may have been changed if we stepped into a library or some
" other piece of code in an another file.  load the new file if thats
" necessary and then jump to lineNumber
"
" returns a fileName.
function! s:JumpToLine(lineNumber, fileName)
   let l:fileName = a:fileName

   " no buffer with this file has been loaded
   if !bufexists(bufname(l:fileName))
      exe ":e! " . l:fileName
   endif

   let l:winNr = bufwinnr(bufnr(l:fileName))
   if l:winNr != -1
      exe l:winNr . "wincmd w"
   endif

   " make a:fileName the current buffer
   if bufname(l:fileName) != bufname("%")
      exe ":buffer " . bufnr(l:fileName)
   endif

   " jump to line
   exe ":" . a:lineNumber
   normal z.
   if foldlevel(a:lineNumber) != 0
      normal zo
   endif

   return bufname(l:fileName)
endfunction
function! s:UnplaceTheLastCurrentLineSign()
   let l:lastId = s:CreateId(s:bufNr, s:lineNumber)
   exe 'sign unplace ' . l:lastId
   if count(s:breakPoints, l:lastId) == 1
      exe "sign place " . l:lastId . " line=" . s:lineNumber . " name=breakPoint file=" . s:fileName
   endif
endfunction
function! s:PlaceCurrentLineSign(lineNumber, fileName)
   let l:bufNr = bufnr(a:fileName)
   let s:bufNr = l:bufNr
   let l:id    = s:CreateId(l:bufNr, a:lineNumber)

   if count(s:breakPoints, l:id) == 1
      exe "sign place " . l:id .
        \ " line=" . a:lineNumber . " name=both file=" . a:fileName
   else
      exe "sign place " . l:id .
        \ " line=" . a:lineNumber . " name=currentLine file=" . a:fileName
   endif
endfunction
function! s:HandleProgramTermination()
   call s:UnplaceTheLastCurrentLineSign()
   let s:lineNumber  = 0
   let s:bufNr       = 0
   let s:programDone = 1
endfunction


" debugger console functions
function! DBGRopenConsole()
   if g:DBGRshowConsole == 0
      return 0
   endif
   new "debugger console"
   let s:consoleBufNr = bufnr('%')
   exe "resize " . g:DBGRconsoleHeight
   exe "sign place 9999 line=1 name=empty buffer=" . s:consoleBufNr
   call s:SetNumber()
   set buftype=nofile
   wincmd p
endfunction
function! DBGRcloseConsole()
   if g:DBGRshowConsole == 0
      return 0
   endif
   let l:consoleWinNr = bufwinnr(s:consoleBufNr)
   if l:consoleWinNr == -1
      return
   endif
   exe l:consoleWinNr . "wincmd w"
   q
endfunction
function! s:ConsolePrint(msg)
   if g:DBGRshowConsole == 0
      return 0
   endif
   let l:consoleWinNr = bufwinnr(s:consoleBufNr)
   if l:consoleWinNr == -1
      "call confirm(a:msg, "&Ok")
      call DBGRopenConsole()
      let l:consoleWinNr = bufwinnr(s:consoleBufNr)
   endif
   silent exe l:consoleWinNr . "wincmd w"
   let l:oldValue = @x
   let @x = a:msg
   silent exe 'normal G$"xp'
   let @x = l:oldValue
   normal G
   wincmd p
endfunction

" debugger variables view functions
function! DBGRopenVariablesView()
   if g:DBGRshowVarView == 0
      return 0
   endif
   rightbelow vertical new "variable view"
   let s:varViewBufNr = bufnr('%')
   set buftype=nofile
   wincmd p
endfunction
function! DBGRcloseVariablesView()
   if g:DBGRshowVarView == 0
      return 0
   endif
   let l:varViewWinNr = bufwinnr(s:varViewBufNr)
   if l:varViewWinNr == -1
      return
   endif
   exe l:varViewWinNr . "wincmd w"
   q
endfunction
function! s:VarViewPrint(msg)
   if g:DBGRshowVarView == 0
      return 0
   endif

   " trim out the display so that only the variables show
   let secondIndex = stridx(a:msg, '')
   let newLength = secondIndex - 2
   let l:trimmedMsg = strpart(a:msg, 2 , newLength)
   let l:varViewWinNr = bufwinnr(s:varViewBufNr)

   if l:varViewWinNr == -1
      "call confirm(a:msg, "&Ok")
      call DBGRopenVariablesView()
      let l:varViewWinNr = bufwinnr(s:varViewBufNr)
   endif
   silent exe l:varViewWinNr . "wincmd w"
   "   let l:oldValue = @x
   let @x = l:trimmedMsg
   silent exe 'normal gg0dG"xp'
   "   let @x = l:oldValue
   setlocal fdm=expr
   setlocal foldexpr=VarViewFoldMethod(v:lnum)
   normal gg
   wincmd p
endfunction

function! IndentLevel(lnum)
   return indent(a:lnum)
endfunction

function! VarViewFoldMethod(lnum)
   if getline(a:lnum) =~? '\v^\x*$'
      return -1
   endif
   return IndentLevel(a:lnum)

   return '0'
endfunction

" debugger stack trace functions
function! DBGRopenStackTraceView()
   if g:DBGRshowStackTraceView == 0
      return 0
   endif
   " below new "stack trace view"
   botright new "stack trace view"
   exe "resize " . g:DBGRstackTraceHeight
   let s:stackTraceViewBufNr = bufnr('%')
   set buftype=nofile
   :file "stack trace view"
   wincmd p
endfunction
function! DBGRcloseStackTraceView()
   if g:DBGRshowStackTraceView == 0
      return 0
   endif
   let l:stackTraceViewWinNr = bufwinnr(s:stackTraceViewBufNr)
   if l:stackTraceViewWinNr == -1
      return
   endif
   exe l:stackTraceViewWinNr . "wincmd w"
   q
endfunction
function! s:StackTraceViewPrint(msg)
   if g:DBGRshowStackTraceView == 0
      return 0
   endif

   if !exists("s:stackTraceViewBufNr")
      call DBGRopenStackTraceView()
   endif

   " trim out the display so that only the variables show
   let secondIndex = stridx(a:msg, '')
   let newLength = secondIndex - 2
   let l:trimmedMsg = strpart(a:msg, 2 , newLength)
   let l:stackTraceViewWinNr = bufwinnr(s:stackTraceViewBufNr)

   if l:stackTraceViewWinNr == -1
      "call confirm(a:msg, "&Ok")
      call DBGRopenStackTraceView()
      let l:stackTraceViewWinNr = bufwinnr(s:stackTraceViewBufNr)
   endif
   silent exe l:stackTraceViewWinNr . "wincmd w"
   "   let l:oldValue = @x
   let @x = l:trimmedMsg
   silent exe 'normal gg0dG"xp'
   "   let @x = l:oldValue
   normal gg
   wincmd p
endfunction

" socket functions
function! s:StartVdd()
   if !executable('vdd')
      echo "\rvdd is not in your PATH.  Something went wrong with your install."
      throw "\rvdd is not in your PATH.  Something went wrong with your install."
   endif
   exec "silent :! vdd &"
endfunction
function! s:Handshake()
    let l:msg  = "start:" . s:sessionId .
               \      ":" . s:debugger  .
               \      ":" . s:incantation
    call s:SocketWrite(l:msg)
endfunction
function! s:SocketConnect()
   perl << EOF
      use IO::Socket;
      foreach my $i (0..9) {
         $DBGRsocket1 = IO::Socket::INET->new(
            Proto    => "tcp",
            PeerAddr => "localhost",
            PeerPort => "6543",
         );
         return if defined $DBGRsocket1;
         sleep 1;
      }
      my $msg = "cannot connect to port 6543 at localhost";
      VIM::Msg($msg);
      VIM::DoCommand("throw '${msg}'");
EOF
endfunction
function! s:SocketRead()
   try 
      " yeah this is a very inefficient but non blocking loop.
      " vdd signals that its done sending a msg when it touches the file.
      " while VimDebug thinks, the user can cancel their operation.
      while !filereadable(s:DONE_FILE)
      endwhile
   catch /Vim:Interrupt/
      echom "action cancelled"
      call s:SocketWrite2('stop:' . s:sessionId)  " disconnect
      call s:HandleCmdResult2()                   " handle disconnect
      call s:SocketConnect2()                     " reconnect
      call s:HandleCmdResult2()                   " handle reconnect
   endtry
   
   perl << EOF
      my $EOM     = VIM::Eval('s:EOM');
      my $EOM_LEN = VIM::Eval('s:EOM_LEN');
      my $data = '';
      $data .= <$DBGRsocket1> until substr($data, -1 * $EOM_LEN) eq $EOM;
      $data .= <$DBGRsocket1> until substr($data, -1 * $EOM_LEN) eq $EOM;
      $data = substr($data, 0, -1 * $EOM_LEN); # chop EOM
      $data =~ s|'|''|g; # escape single quotes '
      VIM::DoCommand("call delete(s:DONE_FILE)");
      VIM::DoCommand("return '" . $data . "'"); 
EOF
endfunction
function! s:SocketWrite(data)
   perl print $DBGRsocket1 VIM::Eval('a:data') . "\n";
endfunction
" TODO: figure out how to and pass perl vars into vim functions so we don't
" have duplicate code
function! s:SocketConnect2()
   perl << EOF
      use IO::Socket;
      foreach my $i (0..9) {
         $DBGRsocket2 = IO::Socket::INET->new(
            Proto    => "tcp",
            PeerAddr => "localhost",
            PeerPort => "6543",
         );
         return if defined $DBGRsocket2;
         sleep 1;
      }
      my $msg = "cannot connect to port 6543 at localhost";
      VIM::Msg($msg);
      VIM::DoCommand("throw '${msg}'");
EOF
endfunction
function! s:SocketRead2()
   try 
      " yeah this is a very inefficient but non blocking loop.
      " vdd signals that its done sending a msg when it touches the file.
      " while VimDebug thinks, the user can cancel their operation.
      while !filereadable(s:DONE_FILE)
      endwhile
   endtry
   
   perl << EOF
      my $EOM     = VIM::Eval('s:EOM');
      my $EOM_LEN = VIM::Eval('s:EOM_LEN');
      my $data = '';
      $data .= <$DBGRsocket2> until substr($data, -1 * $EOM_LEN) eq $EOM;
      $data .= <$DBGRsocket2> until substr($data, -1 * $EOM_LEN) eq $EOM;
      $data = substr($data, 0, -1 * $EOM_LEN); # chop EOM
      $data =~ s|'|''|g; # escape single quotes '
      VIM::DoCommand("call delete(s:DONE_FILE)");
      VIM::DoCommand("return '" . $data . "'"); 
EOF
endfunction
function! s:SocketWrite2(data)
   perl print $DBGRsocket2 VIM::Eval('a:data') . "\n";
endfunction
function! s:HandleCmdResult2(...)
    let l:foo = s:SocketRead2()
    return
endfunction
