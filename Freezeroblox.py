# imports
import psutil
from PyQt5.QtWidgets import (QApplication, QWidget, QVBoxLayout, QHBoxLayout,
                              QCheckBox, QDoubleSpinBox, QLabel,
                              QPushButton, QMessageBox, QLineEdit,
                              QSlider, QGroupBox, QProgressDialog)
from PyQt5.QtCore import Qt, QEventLoop, QTimer, QThread, pyqtSignal
from PyQt5.QtGui import QFont, QFontDatabase, QIcon
import keyboard
import qdarkstyle
import urllib.request, json
import webbrowser
import sys, os, subprocess, tempfile

# ── version ───────────────────────────────────────────────────────────────────
CURRENT_VERSION = "3.0.0"
GITHUB_API      = "https://api.github.com/repos/LukeDevsE/FreezeSwitchV2/releases"
# ─────────────────────────────────────────────────────────────────────────────

basedir = os.path.dirname(sys.executable if getattr(sys, 'frozen', False) else __file__)

def get_process_id_by_name(name):
    for proc in psutil.process_iter(['pid', 'name']):
        if proc.info['name'] == name:
            return proc.info['pid']
    return None

pid = get_process_id_by_name("RobloxPlayerBeta.exe")
DEFAULT_OPACITY = 85
DEFAULT_SCALE   = 100
DEFAULT_TOPMOST = True


# ── Auto-update threads ───────────────────────────────────────────────────────
class UpdateChecker(QThread):
    update_available = pyqtSignal(str, str)
    no_update        = pyqtSignal()
    check_failed     = pyqtSignal(str)

    def run(self):
        try:
            req = urllib.request.Request(GITHUB_API,
                  headers={"User-Agent": "FreezeSwitchV3"})
            with urllib.request.urlopen(req, timeout=6) as r:
                releases = json.load(r)
            if not releases:
                self.no_update.emit(); return
            latest = releases[0]
            tag    = latest.get("tag_name", "").lstrip("v")
            dl_url = ""
            for a in latest.get("assets", []):
                if a["name"].lower().endswith(".exe"):
                    dl_url = a["browser_download_url"]; break
            if tag and tag != CURRENT_VERSION and dl_url:
                self.update_available.emit(tag, dl_url)
            else:
                self.no_update.emit()
        except Exception as e:
            self.check_failed.emit(str(e))


class Downloader(QThread):
    progress = pyqtSignal(int)
    finished = pyqtSignal(str)
    failed   = pyqtSignal(str)

    def __init__(self, url):
        super().__init__()
        self.url = url

    def run(self):
        try:
            tmp = tempfile.mktemp(suffix=".exe", prefix="FSV3_new_")
            req = urllib.request.Request(self.url,
                  headers={"User-Agent": "FreezeSwitchV3"})
            with urllib.request.urlopen(req) as r:
                total = int(r.headers.get("Content-Length", 0))
                done  = 0
                with open(tmp, "wb") as f:
                    while True:
                        buf = r.read(8192)
                        if not buf: break
                        f.write(buf)
                        done += len(buf)
                        if total:
                            self.progress.emit(int(done * 100 / total))
            self.finished.emit(tmp)
        except Exception as e:
            self.failed.emit(str(e))
# ─────────────────────────────────────────────────────────────────────────────


def apply_update(new_exe, font, parent):
    current_exe = sys.executable if getattr(sys, 'frozen', False) else ""
    if not current_exe or not current_exe.lower().endswith(".exe"):
        QMessageBox.information(parent, "Downloaded",
            f"Update saved to:\n{new_exe}\nReplace the .exe manually.")
        return
    bat = tempfile.mktemp(suffix=".bat")
    with open(bat, "w") as f:
        f.write(f"""@echo off
:loop
tasklist /FI "PID eq {os.getpid()}" 2>NUL | find "{os.getpid()}" >NUL
if not errorlevel 1 ( timeout /t 1 /nobreak >NUL & goto loop )
move /Y "{new_exe}" "{current_exe}"
start "" "{current_exe}"
del "%~f0"
""")
    subprocess.Popen(["cmd", "/c", bat], creationflags=subprocess.CREATE_NO_WINDOW)
    QApplication.quit()


def check_for_updates(parent, base_font, silent=True):
    checker = UpdateChecker()

    def on_available(new_ver, dl_url):
        mb = QMessageBox(parent)
        mb.setWindowTitle("Update Available!")
        mb.setText(f"v{new_ver} is available!\n\nDownload and install now?")
        mb.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        mb.setFont(base_font)
        mb.setWindowIcon(QIcon(os.path.join(basedir, 'icon.png')))
        if mb.exec_() != QMessageBox.Yes: return
        prog = QProgressDialog("Downloading…", "Cancel", 0, 100, parent)
        prog.setWindowTitle("Downloading update")
        prog.setWindowModality(Qt.WindowModal)
        prog.setFont(base_font); prog.show()
        dl = Downloader(dl_url)
        dl.progress.connect(prog.setValue)
        dl.finished.connect(lambda path: (prog.close(), apply_update(path, base_font, parent)))
        dl.failed.connect(lambda err: (prog.close(),
            QMessageBox.critical(parent, "Download Failed", err)))
        prog.canceled.connect(dl.terminate)
        dl.start()
        parent._dl = dl

    def on_fail(err):
        if not silent:
            QMessageBox.warning(parent, "Check Failed", err)

    def on_no():
        if not silent:
            QMessageBox.information(parent, "Up to date",
                f"You already have the latest version (v{CURRENT_VERSION})!")

    checker.update_available.connect(on_available)
    checker.no_update.connect(on_no)
    checker.check_failed.connect(on_fail)
    checker.start()
    parent._checker = checker


# ── Main UI ───────────────────────────────────────────────────────────────────
def main():
    app = QApplication([])
    app.setStyleSheet(qdarkstyle.load_stylesheet(qt_api='pyqt5'))

    QFontDatabase.addApplicationFont(os.path.join(basedir, 'Geologica-Medium.ttf'))
    base_font = QFont("Geologica Roman Medium", 8)

    window = QWidget()
    flags = Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
    if DEFAULT_TOPMOST:
        flags |= Qt.WindowStaysOnTopHint
    window.setWindowFlags(flags)
    window.setWindowOpacity(DEFAULT_OPACITY / 100)
    window.setWindowIcon(QIcon(os.path.join(basedir, 'icon.png')))
    window.setWindowTitle(f"Freeze Switch V3  •  v{CURRENT_VERSION}")

    root = QVBoxLayout()
    root.setSpacing(6)
    root.setContentsMargins(8, 8, 8, 8)

    # ── Freeze ────────────────────────────────────────────────────────────────
    freeze_btn = QCheckBox("Freeze Roblox!")
    freeze_btn.setFont(base_font)

    # ── Hotkey row ────────────────────────────────────────────────────────────
    key_row = QHBoxLayout()
    key_lbl = QLabel("Hotkey:"); key_lbl.setFont(base_font)

    key_input = QLineEdit()
    key_input.setReadOnly(True); key_input.setText("`")
    key_input.setFont(base_font); key_input.setFixedWidth(72)
    key_input.setAlignment(Qt.AlignCenter)

    def kp(event):
        t = event.text()
        if t:
            key_input.setText(t)
        else:
            sp = {Qt.Key_F1:"f1",Qt.Key_F2:"f2",Qt.Key_F3:"f3",Qt.Key_F4:"f4",
                  Qt.Key_F5:"f5",Qt.Key_F6:"f6",Qt.Key_F7:"f7",Qt.Key_F8:"f8",
                  Qt.Key_F9:"f9",Qt.Key_F10:"f10",Qt.Key_F11:"f11",Qt.Key_F12:"f12",
                  Qt.Key_Insert:"insert",Qt.Key_Delete:"delete",
                  Qt.Key_Home:"home",Qt.Key_End:"end",
                  Qt.Key_PageUp:"page up",Qt.Key_PageDown:"page down",
                  Qt.Key_Up:"up",Qt.Key_Down:"down",
                  Qt.Key_Left:"left",Qt.Key_Right:"right",
                  Qt.Key_CapsLock:"caps lock",Qt.Key_Tab:"tab",
                  Qt.Key_Escape:"esc",Qt.Key_Backspace:"backspace",
                  Qt.Key_Return:"enter",Qt.Key_Enter:"enter"}
            n = sp.get(event.key())
            if n: key_input.setText(n)
    key_input.keyPressEvent = kp

    set_key_btn = QPushButton("Set Key")
    set_key_btn.setFont(base_font); set_key_btn.setFixedWidth(58)
    set_key_btn.clicked.connect(lambda: key_input.setFocus())

    key_row.addWidget(key_lbl)
    key_row.addWidget(key_input)
    key_row.addWidget(set_key_btn)

    # ── Cooldown ──────────────────────────────────────────────────────────────
    cd_lbl = QLabel("Auto-unfreeze seconds (0 = off, max 9.0):")
    cd_lbl.setFont(base_font); cd_lbl.setWordWrap(True)

    cooldown = QDoubleSpinBox()
    cooldown.setRange(0.0, 9.0); cooldown.setSingleStep(0.1)
    cooldown.setDecimals(1); cooldown.setValue(0.0)
    cooldown.setFont(base_font)

    # ── Settings panel ────────────────────────────────────────────────────────
    settings_btn = QPushButton("⚙  Settings ▼")
    settings_btn.setFont(base_font); settings_btn.setCheckable(True)

    sbox = QGroupBox("Settings"); sbox.setFont(base_font)
    sl = QVBoxLayout(); sl.setSpacing(5); sbox.setLayout(sl); sbox.setVisible(False)

    # Always on top
    topmost_cb = QCheckBox("Always on Top")
    topmost_cb.setFont(base_font); topmost_cb.setChecked(DEFAULT_TOPMOST)
    def on_top(s):
        f = Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
        if s: f |= Qt.WindowStaysOnTopHint
        p = window.pos(); window.setWindowFlags(f); window.move(p); window.show()
    topmost_cb.stateChanged.connect(on_top)

    # Opacity
    op_lbl = QLabel(f"Opacity: {DEFAULT_OPACITY}%"); op_lbl.setFont(base_font)
    op_sl  = QSlider(Qt.Horizontal); op_sl.setRange(20, 100); op_sl.setValue(DEFAULT_OPACITY)
    def on_op(v): op_lbl.setText(f"Opacity: {v}%"); window.setWindowOpacity(v / 100)
    op_sl.valueChanged.connect(on_op)

    # UI Scale
    sc_lbl = QLabel(f"UI Scale: {DEFAULT_SCALE}%"); sc_lbl.setFont(base_font)
    sc_sl  = QSlider(Qt.Horizontal); sc_sl.setRange(70, 200); sc_sl.setValue(DEFAULT_SCALE)
    fw = [freeze_btn, key_lbl, key_input, set_key_btn, cd_lbl, cooldown,
          settings_btn, sbox, topmost_cb, op_lbl, sc_lbl]
    def on_sc(v):
        sc_lbl.setText(f"UI Scale: {v}%")
        f = QFont("Geologica Roman Medium", max(6, int(8 * v / 100)))
        for w in fw: w.setFont(f)
        window.setMinimumSize(0, 0); window.adjustSize()
        window.setFixedSize(window.sizeHint())
    sc_sl.valueChanged.connect(on_sc)

    # Update button
    upd_btn = QPushButton("🔄  Check for Updates"); upd_btn.setFont(base_font)
    upd_btn.clicked.connect(lambda: check_for_updates(window, base_font, silent=False))
    ver_lbl = QLabel(f"Current version: v{CURRENT_VERSION}")
    ver_lbl.setFont(base_font); ver_lbl.setAlignment(Qt.AlignCenter)

    sl.addWidget(topmost_cb)
    sl.addWidget(op_lbl); sl.addWidget(op_sl)
    sl.addWidget(sc_lbl); sl.addWidget(sc_sl)
    sl.addWidget(upd_btn); sl.addWidget(ver_lbl)

    def toggle_panel(c):
        sbox.setVisible(c)
        settings_btn.setText("⚙  Settings ▲" if c else "⚙  Settings ▼")
        window.setMinimumSize(0, 0); window.adjustSize()
        window.setFixedSize(window.sizeHint())
    settings_btn.toggled.connect(toggle_panel)

    # ── Assemble ──────────────────────────────────────────────────────────────
    root.addWidget(freeze_btn)
    root.addLayout(key_row)
    root.addWidget(cd_lbl)
    root.addWidget(cooldown)
    root.addWidget(settings_btn)
    root.addWidget(sbox)
    window.setLayout(root)

    keyboard.hook(lambda e: Toggletoggle(freeze_btn, key_input.text(), cooldown.value()))
    freeze_btn.clicked.connect(lambda: toggle(freeze_btn.isChecked(), cooldown.value(), freeze_btn))

    window.show()
    window.setFixedSize(window.sizeHint())

    # Auto-check updates 2s after launch
    QTimer.singleShot(2000, lambda: check_for_updates(window, base_font, silent=True))

    app.exec_()


# ── Hotkey / freeze logic ─────────────────────────────────────────────────────
def Toggletoggle(button, key, cd):
    if not key: return
    try:
        if keyboard.is_pressed(key) and button.isEnabled():
            button.setChecked(not button.isChecked())
            toggle(button.isChecked(), cd, button)
    except Exception as e:
        print(f"Key error: {e}")


def toggle(checked, cd, button):
    pid = globals()["pid"]
    def refresh():
        globals()["pid"] = get_process_id_by_name("RobloxPlayerBeta.exe")
        return globals()["pid"]
    def suspend(p):
        try: psutil.Process(p).suspend()
        except: pass
    def resume(p):
        try: psutil.Process(p).resume()
        except: pass

    if checked:
        if pid is None: pid = refresh()
        if pid: suspend(pid)
        if cd > 0:
            button.setDisabled(True)
            loop = QEventLoop()
            QTimer.singleShot(int(cd * 1000), loop.quit)
            loop.exec_()
            button.setDisabled(False)
            if pid: resume(pid)
            button.setChecked(False)
    else:
        if pid is None: pid = refresh()
        if pid: resume(pid)


if __name__ == "__main__":
    main()
