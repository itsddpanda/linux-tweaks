#!/bin/bash

# ================= CONFIGURATION =================
# Replace this with the RAW url of your github file
GITHUB_BASHRC_URL="https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/custom_bashrc"

THEME_FILE="$HOME/.custom_theme.sh"
SYSTEM_BASHRC="$HOME/.bashrc"
# =================================================

print_header() {
    clear
    echo -e "\033[1;36m==========================================\033[0m"
    echo -e "\033[1;37m        TERMINAL THEME ENGINE             \033[0m"
    echo -e "\033[1;36m==========================================\033[0m\n"
}

# --- FONT INSTALLATION LOGIC ---
install_fonts() {
    echo -e "\n[*] Checking for Nerd Fonts..."
    if grep -qi "microsoft\|wsl" /proc/version >/dev/null 2>&1; then
        echo "[*] WSL detected. Installing MesloLGS Nerd Font to Windows Host..."
        echo -e "\033[1;33m[!] A Windows prompt (UAC) will appear asking for Admin permissions.\033[0m"
        
        cat << 'EOF' > /tmp/install_font.ps1
$url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/MesloLGS%20Nerd%20Font%20Regular.ttf"
$fontPath = "$env:TEMP\MesloLGS_NF.ttf"
Write-Host "Downloading Font..."
Invoke-WebRequest -Uri $url -OutFile $fontPath
$shellApp = New-Object -ComObject Shell.Application
$fontsFolder = $shellApp.Namespace(0x14)
$fontsFolder.CopyHere($fontPath, 0x10)
Write-Host "Font Installed!"
EOF
        powershell.exe -ExecutionPolicy Bypass -File /tmp/install_font.ps1
        rm /tmp/install_font.ps1
        echo -e "\033[1;32m[✓] Font installed. Remember to set your terminal font to 'MesloLGS NF' in Windows settings!\033[0m"
    else
        echo "[*] Native Linux detected. Installing font..."
        mkdir -p ~/.local/share/fonts
        curl -s -fLo ~/.local/share/fonts/MesloLGS_NF.ttf https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/MesloLGS%20Nerd%20Font%20Regular.ttf
        fc-cache -f -v >/dev/null 2>&1
        echo -e "\033[1;32m[✓] Font installed.\033[0m"
    fi
    sleep 3
}

# --- INSTALLATION CORE ---
do_install() {
    print_header
    install_fonts
    
    echo "[*] Downloading custom theme file from GitHub..."
    curl -s -fLo "$THEME_FILE" "$GITHUB_BASHRC_URL"
    
    if [ ! -f "$THEME_FILE" ]; then
        echo -e "\033[1;31m[x] Error downloading file. Check your GitHub URL.\033[0m"
        read -p "Press Enter to return..."
        return
    fi

    # Check if we already sourced it in the system bashrc
    if ! grep -q "source ~/.custom_theme.sh" "$SYSTEM_BASHRC"; then
        echo -e "\n# Load custom terminal theme\nsource ~/.custom_theme.sh" >> "$SYSTEM_BASHRC"
        echo -e "\033[1;32m[✓] Added theme hook to ~/.bashrc\033[0m"
    fi

    echo -e "\n\033[1;32m[✓] Installation complete!\033[0m"
    echo "To apply changes, restart your terminal or run: source ~/.bashrc"
    read -p "Press Enter to return to main menu..."
}

# --- THEME ENGINE LOGIC ---
update_theme_var() {
    local var_name=$1
    local new_val=$2
    sed -i "s|^${var_name}=.*|${var_name}=\"${new_val}\"|" "$THEME_FILE"
}

icon_menu() {
    while true; do
        print_header
        echo "Select which icon to change:"
        echo "1. Git Repo Icon"
        echo "2. Branch Icon"
        echo "3. Worktree Icon"
        echo "4. Go Back"
        read -p "Select [1-4]: " choice
        
        case $choice in
            1)
                echo -e "\nChoose Git Repo Icon:"
                echo "1)    (FontAwesome)"
                echo "2)    (Devicons)"
                echo "3)    (Git Alt)"
                read -p "Select [1-3] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    2) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    3) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    b) continue ;;
                esac
                ;;
            2)
                echo -e "\nChoose Branch Icon:"
                echo "1)    (Powerline)"
                echo "2)    (Fork)"
                echo "3)    (Octicon Branch)"
                read -p "Select [1-3] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_BRANCH" "" ;;
                    2) update_theme_var "PROMPT_ICON_BRANCH" "" ;;
                    3) update_theme_var "PROMPT_ICON_BRANCH" "" ;;
                    b) continue ;;
                esac
                ;;
            3)
                echo -e "\nChoose Worktree Icon:"
                echo "1) 󰙨   (Repo structure)"
                echo "2)    (Tree)"
                echo "3) 󰊢   (Branching)"
                read -p "Select [1-3] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_WORKTREE" "󰙨" ;;
                    2) update_theme_var "PROMPT_ICON_WORKTREE" "" ;;
                    3) update_theme_var "PROMPT_ICON_WORKTREE" "󰊢" ;;
                    b) continue ;;
                esac
                ;;
            4) return ;;
        esac
        echo -e "\033[1;32mIcon updated! Run 'source ~/.bashrc' in a new tab to see changes.\033[0m"
        sleep 1.5
    done
}

color_menu() {
    while true; do
        print_header
        echo "Select which block to colorize:"
        echo "1. User/Hostname Block"
        echo "2. Folder Block"
        echo "3. Git Block"
        echo "4. Go Back"
        read -p "Select [1-4]: " choice
        
        case $choice in
            1)
                echo -e "\nUser/Host Palette Options (Live Preview):"
                echo -e "1) \033[48;5;236m\033[38;5;255m user@host \033[0m  (Dark Gray / White)"
                echo -e "2) \033[48;5;93m\033[38;5;255m user@host \033[0m  (Purple / White)"
                echo -e "3) \033[48;5;17m\033[38;5;250m user@host \033[0m  (Deep Blue / Light Gray)"
                read -p "Select [1-3] or 'b' to go back: " cc
                case $cc in
                    1) update_theme_var "COLOR_USER_BG" "\033[48;5;236m"; update_theme_var "COLOR_USER_FG" "\033[38;5;255m" ;;
                    2) update_theme_var "COLOR_USER_BG" "\033[48;5;93m"; update_theme_var "COLOR_USER_FG" "\033[38;5;255m" ;;
                    3) update_theme_var "COLOR_USER_BG" "\033[48;5;17m"; update_theme_var "COLOR_USER_FG" "\033[38;5;250m" ;;
                    b) continue ;;
                esac
                ;;
            2)
                echo -e "\nFolder Palette Options (Live Preview):"
                echo -e "1) \033[48;5;117m\033[38;5;232m ~/Project/Folder \033[0m  (Vivid Cyan / Black)"
                echo -e "2) \033[48;5;84m\033[38;5;232m ~/Project/Folder \033[0m  (Bright Mint / Black)"
                echo -e "3) \033[48;5;222m\033[38;5;236m ~/Project/Folder \033[0m  (Soft Yellow / Dark Gray)"
                read -p "Select [1-3] or 'b' to go back: " cc
                case $cc in
                    1) update_theme_var "COLOR_DIR_BG" "\033[48;5;117m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;232m" ;;
                    2) update_theme_var "COLOR_DIR_BG" "\033[48;5;84m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;232m" ;;
                    3) update_theme_var "COLOR_DIR_BG" "\033[48;5;222m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;236m" ;;
                    b) continue ;;
                esac
                ;;
            3)
                echo -e "\nGit Palette Options (Live Preview):"
                echo -e "1) \033[48;5;202m\033[38;5;255m  repo-name \033[0m  (Git Orange / White)"
                echo -e "2) \033[48;5;88m\033[38;5;255m  repo-name \033[0m  (Deep Red / White)"
                echo -e "3) \033[48;5;28m\033[38;5;255m  repo-name \033[0m  (Forest Green / White)"
                read -p "Select [1-3] or 'b' to go back: " cc
                case $cc in
                    1) update_theme_var "COLOR_GIT_BG" "\033[48;5;202m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    2) update_theme_var "COLOR_GIT_BG" "\033[48;5;88m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    3) update_theme_var "COLOR_GIT_BG" "\033[48;5;28m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    b) continue ;;
                esac
                ;;
            4) return ;;
        esac
        echo -e "\033[1;32mColors updated! Run 'source ~/.bashrc' in a new tab to see changes.\033[0m"
        sleep 1.5
    done
}

theme_menu() {
    while true; do
        print_header
        echo "What would you like to customize?"
        echo "1. Git Icons"
        echo "2. Color Palettes (Live Preview)"
        echo "3. Go Back"
        echo "4. Exit"
        read -p "Select [1-4]: " choice
        case $choice in
            1) icon_menu ;;
            2) color_menu ;;
            3) return ;;
            4) exit 0 ;;
            *) echo "Invalid option." ; sleep 1 ;;
        esac
    done
}

# --- MAIN LOOP ---
while true; do
    print_header
    
    # Check if the hook exists in the bashrc to determine what menu options to show
    if grep -q "source ~/.custom_theme.sh" "$SYSTEM_BASHRC"; then
        echo "1. Customize & Install Theme (Force Update from GitHub)"
        echo "2. Theme Engine (Edit Icons & Colors)"
        echo "3. Revert to System Original (Remove Theme)"
        echo "4. Exit"
        read -p "Select [1-4]: " main_choice
        
        case $main_choice in
            1) do_install ;;
            2) theme_menu ;;
            3) 
                # Use sed to safely remove ONLY our hook line
                sed -i '/source ~\/.custom_theme.sh/d' "$SYSTEM_BASHRC"
                sed -i '/# Load custom terminal theme/d' "$SYSTEM_BASHRC"
                echo -e "\033[1;32m[✓] Removed theme hook. System reverted to original state.\033[0m"
                sleep 2
                ;;
            4) exit 0 ;;
            *) echo "Invalid option." ; sleep 1 ;;
        esac
    else
        echo "1. Install Terminal Theme & Fonts"
        echo "2. Exit"
        read -p "Select [1-2]: " main_choice
        
        case $main_choice in
            1) do_install ;;
            2) exit 0 ;;
            *) echo "Invalid option." ; sleep 1 ;;
        esac
    fi
done
