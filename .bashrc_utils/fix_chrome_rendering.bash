function fix_chrome_rendering()
{
    echo "Cleaning up GPUCache..."
    rm -rf "${HOME}/.config/google-chrome/Profile 1/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/Profile 3/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/System Profile/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/Guest Profile/GPUCache/*"
    echo "Restart chrome from the navigation bar with 'chrome://restart'"
}
