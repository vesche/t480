function agnoster::segment --desc 'Create Agnoster prompt segment'
  set bg $argv[1]
  set fg $argv[2]
  set -e argv[1] argv[2]
  set content $argv

  set_color -b $bg

  if set -q __agnoster_background; and [ "$__agnoster_background" != "$bg" ]
    set_color "$__agnoster_background"; echo -n "$AGNOSTER_SEGMENT_SEPARATOR[1]"
  end

  if [ -n "$content" ]
    set -g __agnoster_background $bg
    set_color -b $bg $fg
    echo -n " $content"
  end
end
