function fish_mode_prompt
  if set -q __fish_vi_mode
    switch $fish_bind_mode
      case insert
        set_color green
        echo I
      case visual
        set_color magenta
        echo V
      case replace-one
        set_color green
        echo R
      case default
        set_color blue
        echo N
    end

    set_color normal
  end
end
