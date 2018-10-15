# note: this erases the default fish_mode_prompt, which adds a vi mode
# indicator to the left of your prompt
function fish_mode_prompt; end

# turn on vi mode when the shell starts
fish_vi_key_bindings

# aliases =====================================================================
alias l "ls -GFhl"
alias la "ls -GFhlA"

function fish_prompt
  set -l tomita_vi_mode "$TOMITA_VI"
	echo

	set_color $fish_color_cwd
  printf '%s' (prompt_pwd)

  set_color normal
  printf '%s ' (__fish_git_prompt)

  if test -z (string match -ri '^no|false|0$' $tomita_vi_mode)
    printf '['
    switch $fish_bind_mode
      case default
        set_color --bold red
        printf 'n'
      case insert
        set_color --bold green
        printf 'i'
      case visual
        set_color --bold magenta
        printf 'v'
    end
    set_color normal
    printf '] '
  end

  set_color -o yellow
  printf '⋊> '
  set_color normal
end