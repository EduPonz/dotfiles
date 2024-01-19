function fix_sound()
{
    systemctl --user unmask pulseaudio
    systemctl --user enable pulseaudio
    systemctl --user restart pulseaudio
    systemctl --user status pulseaudio
}
