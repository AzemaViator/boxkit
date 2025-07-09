if status is-interactive
    set -x STARSHIP_CONFIG /etc/starship.toml   # optional global config
    starship init fish | source                 # official init line :contentReference[oaicite:2]{index=2}
end
