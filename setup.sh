#!/bin/bash

# ================= CONFIGURATION =================
# Replace this with the RAW url of your github file
GITHUB_BASHRC_URL="https://raw.githubusercontent.com/itsddpanda/linux-tweaks/main/custom_bashrc"

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
        # Windows/WSL Check: Use PowerShell to check the Windows Registry for the font
        local is_installed=$(powershell.exe -Command "if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue | Out-String) -match 'MesloLGS' -or (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue | Out-String) -match 'MesloLGS') { echo 'yes' } else { echo 'no' }" | tr -d '\r')

        if [[ "$is_installed" == "yes" ]]; then
            echo -e "\033[1;34m[i] MesloLGS Nerd Font is already installed on Windows. Skipping download.\033[0m"
        else
            echo "[*] WSL detected. Installing MesloLGS Nerd Font to Windows Host..."
            echo -e "\033[1;33m[!] A Windows prompt (UAC) will appear asking for Admin permissions.\033[0m"
            
            cat << 'EOF' > /tmp/install_font.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
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
        fi
    else
        # Native Linux Check: Use fc-list to search installed fonts
        if fc-list | grep -qi "MesloLGS NF"; then
            echo -e "\033[1;34m[i] MesloLGS Nerd Font is already installed on Linux. Skipping download.\033[0m"
        else
            echo "[*] Native Linux detected. Installing font..."
            mkdir -p ~/.local/share/fonts
            curl -s -fLo ~/.local/share/fonts/MesloLGS_NF.ttf https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/MesloLGS%20Nerd%20Font%20Regular.ttf
            fc-cache -f -v >/dev/null 2>&1
            echo -e "\033[1;32m[✓] Font installed.\033[0m"
        fi
    fi
    sleep 2
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
        echo "1. Git Repo Icon (Main)"
        echo "2. Git Unsynced Modifier (Shows next to main icon)"
        echo "3. Branch Icon"
        echo "4. Worktree Icon"
        echo "5. Go Back"
        read -p "Select [1-5]: " choice
        
        case $choice in
            1)
                echo -e "\nChoose Git Repo Icon:"
                echo "1)    (FontAwesome)"
                echo "2)    (GitHub Octocat)"
                echo "3)    (Code Angle)"
                echo "4)    (Terminal Window)"
                echo "5)    (Git Square)"
                echo "6)    (Git Commit)"
                echo "7)    (Git Merge)"
                echo "8)    (Git Pull Request)"
                echo "9)    (Git Compare)"
                read -p "Select [1-9] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    2) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    3) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    4) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    5) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    6) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    7) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    8) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    9) update_theme_var "PROMPT_ICON_GIT" "" ;;
                    b) continue ;;
                esac
                ;;
            2)
                echo -e "\nChoose Unsynced Modifier:"
                echo "1)    (Asterisk - Default)"
                echo "2)    (Flame)"
                echo "3)    (Warning Triangle)"
                echo "4)    (Edit Pencil)"
                echo "5) [None] (Color change only)"
                read -p "Select [1-5] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_UNSYNCED_MODIFIER" "" ;;
                    2) update_theme_var "PROMPT_ICON_UNSYNCED_MODIFIER" "" ;;
                    3) update_theme_var "PROMPT_ICON_UNSYNCED_MODIFIER" "" ;;
                    4) update_theme_var "PROMPT_ICON_UNSYNCED_MODIFIER" "" ;;
                    5) update_theme_var "PROMPT_ICON_UNSYNCED_MODIFIER" "" ;;
                    b) continue ;;
                esac
                ;;
            3)
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
            4)
                echo -e "\nChoose Worktree Icon:"
                echo "1)    (Tree)"
                echo "2)    (Hierarchy/Nodes)"
                echo "3)    (Repo Forked)"
                read -p "Select [1-3] or 'b' to go back: " ic
                case $ic in
                    1) update_theme_var "PROMPT_ICON_WORKTREE" "" ;;
                    2) update_theme_var "PROMPT_ICON_WORKTREE" "" ;;
                    3) update_theme_var "PROMPT_ICON_WORKTREE" "" ;;
                    b) continue ;;
                esac
                ;;
            5) return ;;
        esac
        echo -e "\033[1;32mIcon updated! Run 'source ~/.bashrc' in a new tab to see changes.\033[0m"
        sleep 1.5
    done
}

# --- NEW: Reusable Custom Color Input ---
custom_color_picker() {
    local bg_var=$1
    local fg_var=$2
    local preview_text=$3
    
    echo -e "\n--- Custom ANSI 256 Color Mode ---"
    echo "Tip: You can find 0-255 color codes online (e.g., 208 is bright orange)."
    read -p "Enter Background Code (0-255): " bg
    read -p "Enter Text Code (0-255): " fg
    
    echo -e "\nLive Preview: \033[48;5;${bg}m\033[38;5;${fg}m ${preview_text} \033[0m"
    read -p "Apply this custom color? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        update_theme_var "$bg_var" "\033[48;5;${bg}m"
        update_theme_var "$fg_var" "\033[38;5;${fg}m"
        echo -e "\033[1;32mCustom Color Applied!\033[0m"
    fi
}

# --- UPDATED: Symbol Menu ---
symbol_menu() {
    while true; do
        print_header
        echo "Choose Prompt Symbol (Line 2):"
        echo "1) ✒   (Black Nib)"
        echo "2) ➥   (Curved Arrow)"
        echo "3) $   (Standard Dollar)"
        echo "4) ❯   (Chevron)"
        echo "5) Go Back"
        read -p "Select [1-5]: " sym
        case $sym in
            1) update_theme_var "PROMPT_SYMBOL" "✒" ;;
            2) update_theme_var "PROMPT_SYMBOL" "➥" ;;
            3) update_theme_var "PROMPT_SYMBOL" "$" ;;
            4) update_theme_var "PROMPT_SYMBOL" "❯" ;;
            5) return ;;
        esac
        echo -e "\033[1;32mSymbol updated! Source ~/.bashrc to view.\033[0m"
        sleep 1.5
    done
}

# --- UPDATED: Color Menu with Custom Option ---
color_menu() {
    while true; do
        print_header
        echo "Select which block to colorize:"
        echo "1. User/Hostname Block"
        echo "2. Folder Block"
        echo "3. Git Repo Block"
        echo "4. Git Branch/Worktree Block (Synced)"
        echo "5. Git Branch/Worktree Block (UNSYNCED)"
        echo "6. Go Back"
        read -p "Select [1-6]: " choice
        
        case $choice in
            1)
                echo -e "\nUser/Host Palette Options:"
                echo -e "1) \033[48;5;236m\033[38;5;255m user@host \033[0m  (Dark Gray)"
                echo -e "2) \033[48;5;93m\033[38;5;255m user@host \033[0m  (Purple)"
                echo -e "3) \033[48;5;17m\033[38;5;250m user@host \033[0m  (Deep Blue)"
                echo -e "4) \033[1;33m[+] Custom ANSI Code\033[0m"
                read -p "Select [1-4] or 'b': " cc
                case $cc in
                    1) update_theme_var "COLOR_USER_BG" "\033[48;5;236m"; update_theme_var "COLOR_USER_FG" "\033[38;5;255m" ;;
                    2) update_theme_var "COLOR_USER_BG" "\033[48;5;93m"; update_theme_var "COLOR_USER_FG" "\033[38;5;255m" ;;
                    3) update_theme_var "COLOR_USER_BG" "\033[48;5;17m"; update_theme_var "COLOR_USER_FG" "\033[38;5;250m" ;;
                    4) custom_color_picker "COLOR_USER_BG" "COLOR_USER_FG" " user@host " ;;
                    b) continue ;;
                esac
                ;;
            2)
                echo -e "\nFolder Palette Options:"
                echo -e "1) \033[48;5;117m\033[38;5;232m ~/Folder \033[0m  (Vivid Cyan)"
                echo -e "2) \033[48;5;84m\033[38;5;232m ~/Folder \033[0m  (Bright Mint)"
                echo -e "3) \033[48;5;222m\033[38;5;236m ~/Folder \033[0m  (Soft Yellow)"
                echo -e "4) \033[1;33m[+] Custom ANSI Code\033[0m"
                read -p "Select [1-4] or 'b': " cc
                case $cc in
                    1) update_theme_var "COLOR_DIR_BG" "\033[48;5;117m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;232m" ;;
                    2) update_theme_var "COLOR_DIR_BG" "\033[48;5;84m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;232m" ;;
                    3) update_theme_var "COLOR_DIR_BG" "\033[48;5;222m"; update_theme_var "COLOR_DIR_FG" "\033[38;5;236m" ;;
                    4) custom_color_picker "COLOR_DIR_BG" "COLOR_DIR_FG" " ~/Folder " ;;
                    b) continue ;;
                esac
                ;;
            3|4) # Handling both synced git blocks
                echo -e "\nGit Palette Options:"
                echo -e "1) \033[48;5;202m\033[38;5;255m  repo/branch \033[0m  (Git Orange)"
                echo -e "2) \033[48;5;88m\033[38;5;255m  repo/branch \033[0m  (Deep Red)"
                echo -e "3) \033[48;5;28m\033[38;5;255m  repo/branch \033[0m  (Forest Green)"
                echo -e "4) \033[1;33m[+] Custom ANSI Code\033[0m"
                read -p "Select [1-4] or 'b': " cc
                case $cc in
                    1) update_theme_var "COLOR_GIT_BG" "\033[48;5;202m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    2) update_theme_var "COLOR_GIT_BG" "\033[48;5;88m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    3) update_theme_var "COLOR_GIT_BG" "\033[48;5;28m"; update_theme_var "COLOR_GIT_FG" "\033[38;5;255m" ;;
                    4) custom_color_picker "COLOR_GIT_BG" "COLOR_GIT_FG" "  git-text " ;;
                    b) continue ;;
                esac
                ;;
            5) # Unsynced Branch Override
                echo -e "\nUnsynced Branch Color (Warning state):"
                echo -e "1) \033[48;5;166m\033[38;5;255m  main \033[0m  (Dark Orange)"
                echo -e "2) \033[48;5;124m\033[38;5;255m  main \033[0m  (Crimson Alert)"
                echo -e "3) \033[1;33m[+] Custom ANSI Code\033[0m"
                read -p "Select [1-3] or 'b': " cc
                case $cc in
                    1) update_theme_var "COLOR_GIT_UNSYNCED_BG" "\033[48;5;166m" ;;
                    2) update_theme_var "COLOR_GIT_UNSYNCED_BG" "\033[48;5;124m" ;;
                    3) custom_color_picker "COLOR_GIT_UNSYNCED_BG" "COLOR_GIT_FG" "  unsynced " ;;
                    b) continue ;;
                esac
                ;;
            6) return ;;
        esac
        echo -e "\033[1;32mColors updated! Run 'source ~/.bashrc' in a new tab to see changes.\033[0m"
        sleep 1.5
    done
}

# --- UPDATED: Main Theme Menu ---
theme_menu() {
    while true; do
        print_header
        echo "What would you like to customize?"
        echo "1. Git Icons"
        echo "2. Prompt Symbol (Pen/Arrows)"
        echo "3. Color Palettes (Live Preview)"
        echo "4. Go Back"
        echo "5. Exit"
        read -p "Select [1-5]: " choice
        case $choice in
            1) icon_menu ;;
            2) symbol_menu ;;
            3) color_menu ;;
            4) return ;;
            5) exit 0 ;;
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
