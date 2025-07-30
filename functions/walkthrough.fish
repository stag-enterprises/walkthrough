function __walkthrough_log -d "Print a message" -a type msg
    # brblack is typically grey
    set_color --bold --dim brblack
    echo -n "walkthrough "
    switch $type
        case err
            set_color red
            echo -n "err  "
        case warn
            set_color yellow
            echo -n "warn "
        case ok
            set_color green
            echo -n "ok   "
        case info
            set_color cyan
            echo -n "info "
    end
    set_color normal
    echo $msg
end

function __walkthrough_abspath -d "Normalize and absolute a path" -a path
    pushd .
    echo (cd (dirname $path) && pwd)/(basename $path)
    popd
end

function walkthrough -d "Walkthrough a script"
    set -e _flag_help _flag_next _flag_back _flag_again _flag_which _flag_where _flag_reset _flag_goto _flag_list _flag_select _flag_autopilot
    argparse -x next,back,again,goto,which,where,reset,goto,list,select,autopilot \
        h/help n/next b/back a/again w/which e/where r/reset g/goto l/list s/select p/autopilot \
        -- $argv

    if set -q _flag_help
        echo walkthrough script.sh
        echo walkthrough [-hawerlsp]
        echo walkthrough [-nbg] [amount]
        echo
        echo -h,--help
        echo -w,--which -e,--where
        echo -l,--list -s,--select -p,--autopilot,--reset
        echo -n,--next -b,--back -a,--again -g,--goto
        return
    end

    if set -q _flag_which
        echo $__walkthrough_script
    else if set -q _flag_where
        echo $__walkthrough_line
    else if set -q _flag_reset
        set -g __walkthrough_line 1
        __walkthrough_log ok "set line to 1"
    else if set -q _flag_goto
        set -g __walkthrough_line $argv[1]
        __walkthrough_log ok "set line to $argv[1]"
    else if set -q _flag_list
        if ! command -v bat >/dev/null
            __walkthrough_log err "bat is not installed or not in path"
            return
        end
        set -l start (math $__walkthrough_line - 4)
        set -l end (math $__walkthrough_line + 4)
        if [ $start -le 0 ]
            set start 1
        end
        bat $__walkthrough_script \
            --line-range=$start:$end \
            --highlight-line=$__walkthrough_line \
            --style=-grid
    else if set -q _flag_autopilot
        if [ $__walkthrough_line -le 1 ]
            set -g __walkthrough_line 1
        end
        __walkthrough_log info "autopilot starting on line $__walkthrough_line"
        while set -g line (sed -n "$__walkthrough_line p" "$__walkthrough_script")
            if not [ -z "$(string trim $line)" ]
                if eval "$line"
                    __walkthrough_log ok "autopilot: $line"
                else
                    __walkthrough_log err "autopilot: $line"
                    break
                end
            end
            set -g __walkthrough_line (math $__walkthrough_line + 1)
            if [ $__walkthrough_line -ge $__walkthrough_maxlines ]
                set -g __walkthrough_line $__walkthrough_maxlines
                __walkthrough_log info "autopilot: reached end of script"
                break
            end
        end
        set -g __walkthrough_line (math $__walkthrough_line - 1)
        __walkthrough_log info "autopilot finished on line $__walkthrough_line"
    else if set -q _flag_select
        if ! command -v fzf >/dev/null
            __walkthrough_log err "fzf is not installed or not in path"
            return
        end
        __walkthrough_log ok "started command selection"
        commandline (command grep -v '^\s*$' <$__walkthrough_script | fzf)
    else if set -q _flag_again; or set -q _flag_back; or set -q _flag_next
        if set -q argv[1]
            set -f amount $argv[1]
        else
            set -f amount 1
        end
        if set -q _flag_again
            __walkthrough_log info "repeating the line"
            set -f amount 0
        else if set -q _flag_back
            __walkthrough_log info "going back $amount line(s)"
            set -f amount (math $amount x -1)
        else
            __walkthrough_log info "going forward $amount line(s)"
        end
        set -g __walkthrough_line (math $__walkthrough_line + $amount)
        if [ $__walkthrough_line -le 1 ]
            set -g __walkthrough_line 1
        end
        if [ $__walkthrough_line -ge $__walkthrough_maxlines ]
            set -g __walkthrough_line $__walkthrough_maxlines
        end
        set -l line (sed -n $__walkthrough_line"p" $__walkthrough_script)
        if [ -z "$(string trim $line)" ]
            set motion (set -q _flag_next; and echo -n; or echo -b)
            __walkthrough_log info "skipping $(walkthrough $motion | wc -l) empty line(s)"
            return
        end
        commandline $line
    else if set -q argv[1]
        set -g __walkthrough_script (__walkthrough_abspath $argv[1])
        set -g __walkthrough_maxlines (wc -l <$__walkthrough_script)
        set -g __walkthrough_line 1
        if not [ -f $__walkthrough_script ]
            __walkthrough_log err "no such file $argv[1]"
            return
        end
        __walkthrough_log ok "started script $argv[1]"
    else
        walkthrough -n
    end
end
