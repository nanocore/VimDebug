# ABSTRACT: Integrate the Perl debugger with Vim

=head1 What is VimDebug?

VimDebug integrates the Perl debugger with Vim, allowing developers to
visually step through their code, examine variables, set or clear
breakpoints, etc.

VimDebug is known to work under Unix/Ubuntu/OSX. It requires Perl 5.FIXME or
later and some CPAN modules may need to be installed.  It also requires Vim
7.FIXME or later that was built with the +signs and +perl extensions.

=head1 How do I install VimDebug?

VimDebug has a Perl component and a Vim component.

A simple way to install the Perl component is to use
L<cpanminus's|https://metacpan.org/module/App::cpanminus> C<cpanm>
program. First, install C<cpanminus>:

    curl -L http://cpanmin.us | perl - --sudo App::cpanminus

Then, install VimDebug's Perl files:

    cpanm Vim::Debug

Next, install the Vim component, by executing the following program,
supplied by the Perl component:

    vimdebug-install -d ~/.vim

You may want to replace C<~/.vim> by some other directory that your
Vim recognizes as a runtimepath directory. See Vim's ":help
'runtimepath'" for more information.

Finally, install and read the Vim help file, which describes
VimDebug's keymap:

    :helptags ~/.vim/doc
    :help VimDebug

Make sure that the directory where that C<doc> directory resides is in
your Vim runtimepath, else Vim won't find its help information even if
it manages to build the help index.

=head1 Using VimDebug

Launch Vim and open a file named with a ".pl" extension. Press <F12>
to start the debugger. To change the default Vim key bindings, shown
here, edit VimDebug.vim:

    <F12>      Start the debugger
    <Leader>s/ Start the debugger.  Prompts for command line arguments.
    <F10>      Restart debugger. Break points are ALWAYS saved (for all dbgrs).
    <F11>      Exit the debugger

    <F6>       Next
    <F7>       Step
    <F8>       Continue

    <Leader>b  Set break point on the current line, regardless of the debugger running
    <Leader>be Edit the file that has the saved breakpoints
    <Leader>c  Clear break point on the current line
    <Leader>cab  Clear all break points for this debugging session

    <Leader>v  Update the variable view (handy if you have the auto update for
               the variables view turned off
    <Leader>V  Toggle the auto update on the variables view
    <Leader>f  Toggle the folding in the variables view 
    <Leader>s  Toggle the stack trace window

    <Leader>x  Print the value of the variable under the cursor
    <Leader>x/ Print the value of an expression thats entered

    <Leader>/  Type a command for the debugger to execute and echo the result

When running with the GUI version of vim there will be an additional menu item
that has all the necessary debugger commands that can be used rather then the
key mappings.  The main menu item will be named Debugger and has the following
items as sub menu items:
Start
Next
Step
StepOut
Continue
ToggleStackTrace
FoldingVariables
Restart
Quit

Also, when using the GUI version there will be an additional icon placed on the
toolbar that can start the debugger.  Once started it will be replaced with 
6 icons, one for each major debugger function: step, stepout, next, continue,
quit and restart.  Once the debugger is exited the 6 icons will be removed and
the single debugger icon will be show once again.


There are some global variables that you can set in your vimrc (or gvimrc) that
can adjust some of the default functionality.   NOTE: toggles are either 1 for
true or 0 for false
g:DBGRshowConsole               - Toggle the showing of the console (default: 1)
g:DBGRconsoleHeight             - Sets the console height.  The console is 
                                  where the output from the debugger will appear
                                 (default: 7)
g:DBGRlineNumbers               - Toggle line numbers (default: 1)
g:DBGRshowVarView               - Toggle showing the variables view (default: 1)
                                  This view will show all variables and their 
                                  values that are in the current scope.  It will
                                  expand all hash and array variables.
                                  (default: 1)
g:DBGRautoUpdateVarView         - Toggle the automatic update of the variables
                                  view.  This can slow down the stepping through
                                  the debugger if you have lots of large variables
                                  (default: 1)
g:DBGRtoggleFoldingVarView      - Toggle the folding of the variables in the
                                  variables view.  This can be useful if you have
                                  large nested array or hash variables
                                  (default: 1)
g:DBGRshowStackTraceView        - Toggle the showing of the stack trace view
                                  (default: 1)
g:DBGRstackTraceHeight          - Sets the stack trace view height. (default: 7)
g:DBGRautoUpdateStackTraceView  - Toggle the auto update of the stack trace view
                                  (default: 1)
g:DBGRsavedBreakPointsDirectory - Set the directory for the support of VimDebug. 
                                  Currently, the only thing kept in there is the 
                                  saved break points file.
                                  (default: $HOME . "/.vim/vimDBGR")
g:DBGRgeneralBreakPointsFile    - Set the file name of the file that will contain
                                  the list of breakpoints used in all debugging 
                                  sessions.
                                  default: 
                        g:DBGRsavedBreakPointsDirectory . "/.generalBreakPoints"


=head1 Improving VimDebug

VimDebug is on github: https://github.com/kablamo/VimDebug.git

To do development work on VimDebug, clone its git repo and read
./documentation/DEVELOPER.

In principle, the VimDebug code can be extended to handle other
debuggers, like the one for Ruby or Python, but that remains to be
done.

Please note that this code is in beta.

=cut

package Vim::Debug::Manual;

# VERSION

