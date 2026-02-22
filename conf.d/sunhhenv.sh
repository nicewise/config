# -----------------------------------------------------------------------------
# Research toolchain environment (sunhh)
# Location: /etc/profile.d/sunhhenv.sh
# -----------------------------------------------------------------------------

# ---- Base dirs --------------------------------------------------------------
HOME_SUNHH="/home/sunhh"
PERIDIGM_DIR="$HOME_SUNHH/Peridigm"
CLIKE_DIR="$HOME_SUNHH/clike"
TFEL_DIR="$HOME_SUNHH/opt/tfel"

# ---- Helper: add to PATH if not exists --------------------------------------
_path_append() {
    case ":$PATH:" in
        *":$1:"*) ;;  # already exists
        *) export PATH="$PATH:$1" ;;
    esac
}

_ldpath_append() {
    case ":$LD_LIBRARY_PATH:" in
        *":$1:"*) ;;
        *) export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$1" ;;
    esac
}

# ---- PATH: executables ------------------------------------------------------
_path_append "$HOME_SUNHH/.npm-global/bin"
_path_append "$HOME_SUNHH/bin"
_path_append "$TFEL_DIR/bin"

# ---- LD_LIBRARY_PATH: shared libraries --------------------------------------
_ldpath_append "$CLIKE_DIR/lib"
_ldpath_append "$TFEL_DIR/lib"

# ---- C/C++ include search path ---------------------------------------------
export C_INCLUDE_PATH="$CLIKE_DIR/include${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"

# ---- Julia settings ---------------------------------------------------------
export JULIA_PKG_SERVER="https://mirror.nju.edu.cn/julia"
