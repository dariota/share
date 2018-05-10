config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=''") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file ~/.config/share/config "${1}")";
    printf -- "%s" "${val}";
}
