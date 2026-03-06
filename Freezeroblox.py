"""
FreezeSwitchV3 Builder
- ดาวน์โหลด .exe จาก GitHub Releases โดยตรง
- ไม่มี CMD popup
- สร้างโฟลเดอร์ FreezeSwitchV3 และวาง exe ไว้ข้างใน
"""
import sys, os, urllib.request, json, shutil
from PyQt5.QtWidgets import (QApplication, QWidget, QVBoxLayout,
                              QLabel, QPushButton, QTextEdit, QProgressBar,
                              QMessageBox)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QFont
import qdarkstyle

GITHUB_API   = "https://api.github.com/repos/mm3xwqi/s/releases"
OUTPUT_NAME  = "FreezeSwitchV3"
EXE_FILENAME = "FreezeSwitchV3.exe"


class DownloadWorker(QThread):
    log      = pyqtSignal(str)
    progress = pyqtSignal(int)
    done     = pyqtSignal(bool, str)

    def run(self):
        try:
            # ── 1. สร้างโฟลเดอร์ ───────────────────────────────────────────
            base       = os.path.dirname(sys.executable if getattr(sys, 'frozen', False) else __file__)
            out_folder = os.path.join(base, OUTPUT_NAME)
            os.makedirs(out_folder, exist_ok=True)
            self.log.emit(f"📁 สร้างโฟลเดอร์: {out_folder}")
            self.progress.emit(10)

            # ── 2. ดึง releases จาก GitHub ────────────────────────────────
            self.log.emit("🔍 กำลังตรวจสอบ releases จาก GitHub...")
            req = urllib.request.Request(
                GITHUB_API,
                headers={"User-Agent": "FSV3-Builder"}
            )
            with urllib.request.urlopen(req, timeout=10) as r:
                releases = json.load(r)

            if not releases:
                self.done.emit(False, "ไม่พบ releases บน GitHub")
                return

            latest = releases[0]
            tag    = latest.get("tag_name", "ไม่ทราบ")
            assets = latest.get("assets", [])
            self.log.emit(f"📌 พบ version ล่าสุด: {tag}")
            self.progress.emit(20)

            # ── 3. หา .exe ใน assets ──────────────────────────────────────
            dl_url = ""
            for a in assets:
                if a["name"].lower().endswith(".exe"):
                    dl_url   = a["browser_download_url"]
                    filesize = a.get("size", 0)
                    self.log.emit(f"📦 พบไฟล์: {a['name']} ({filesize // 1024:,} KB)")
                    break

            if not dl_url:
                self.done.emit(False,
                    "ไม่พบไฟล์ .exe ใน release นี้\n"
                    "กรุณาอัพโหลด .exe ขึ้น GitHub Releases ก่อนครับ")
                return

            self.progress.emit(30)

            # ── 4. ดาวน์โหลด .exe ────────────────────────────────────────
            self.log.emit("⬇️  กำลังดาวน์โหลด .exe ...")
            exe_path = os.path.join(out_folder, EXE_FILENAME)
            req2 = urllib.request.Request(dl_url, headers={"User-Agent": "FSV3-Builder"})

            with urllib.request.urlopen(req2) as r:
                total    = int(r.headers.get("Content-Length", 0))
                done_b   = 0
                with open(exe_path, "wb") as f:
                    while True:
                        buf = r.read(65536)
                        if not buf:
                            break
                        f.write(buf)
                        done_b += len(buf)
                        if total:
                            pct = 30 + int(65 * done_b / total)
                            self.progress.emit(pct)
                            self.log.emit(
                                f"   {done_b // 1024:,} / {total // 1024:,} KB  "
                                f"({int(done_b * 100 / total)}%)"
                            )

            self.progress.emit(100)
            self.log.emit(f"\n✅ ดาวน์โหลดสำเร็จ!")
            self.done.emit(True, exe_path)

        except Exception as e:
            self.done.emit(False, str(e))


class BuilderWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("FreezeSwitchV3 Installer")
        self.setWindowFlags(Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
                            | Qt.WindowStaysOnTopHint)
        self.setMinimumWidth(480)

        font      = QFont("Segoe UI", 9)
        font_bold = QFont("Segoe UI", 13, QFont.Bold)
        self.setFont(font)

        layout = QVBoxLayout()
        layout.setSpacing(8)
        layout.setContentsMargins(12, 12, 12, 12)

        title = QLabel("❄️  FreezeSwitchV3 Installer")
        title.setFont(font_bold)
        title.setAlignment(Qt.AlignCenter)

        desc = QLabel(
            "กดปุ่ม Download เพื่อ:\n"
            f"  1. ดาวน์โหลด {EXE_FILENAME} จาก GitHub Releases\n"
            f"  2. วางไว้ในโฟลเดอร์ {OUTPUT_NAME}/ ข้างๆ ไฟล์นี้"
        )
        desc.setFont(font)
        desc.setWordWrap(True)

        self.log_box = QTextEdit()
        self.log_box.setReadOnly(True)
        self.log_box.setFont(QFont("Consolas", 8))
        self.log_box.setMinimumHeight(180)

        self.prog_bar = QProgressBar()
        self.prog_bar.setValue(0)
        self.prog_bar.setTextVisible(True)
        self.prog_bar.setMinimumHeight(22)

        self.dl_btn = QPushButton("⬇️  Download FreezeSwitchV3.exe")
        self.dl_btn.setFont(QFont("Segoe UI", 10, QFont.Bold))
        self.dl_btn.setMinimumHeight(38)
        self.dl_btn.clicked.connect(self.start_download)

        self.open_btn = QPushButton("📂  เปิดโฟลเดอร์")
        self.open_btn.setFont(font)
        self.open_btn.setMinimumHeight(30)
        self.open_btn.setEnabled(False)
        self.open_btn.clicked.connect(self.open_folder)

        self.status_lbl = QLabel("พร้อม — กด Download เพื่อเริ่ม")
        self.status_lbl.setAlignment(Qt.AlignCenter)
        self.status_lbl.setFont(font)

        layout.addWidget(title)
        layout.addWidget(desc)
        layout.addWidget(self.log_box)
        layout.addWidget(self.prog_bar)
        layout.addWidget(self.dl_btn)
        layout.addWidget(self.open_btn)
        layout.addWidget(self.status_lbl)
        self.setLayout(layout)

        self._exe_path = ""

    def start_download(self):
        self.dl_btn.setEnabled(False)
        self.open_btn.setEnabled(False)
        self.log_box.clear()
        self.prog_bar.setValue(0)
        self.status_lbl.setText("⏳ กำลังดาวน์โหลด...")

        self.worker = DownloadWorker()
        self.worker.log.connect(self.append_log)
        self.worker.progress.connect(self.prog_bar.setValue)
        self.worker.done.connect(self.on_done)
        self.worker.start()

    def append_log(self, text):
        self.log_box.append(text)
        self.log_box.verticalScrollBar().setValue(
            self.log_box.verticalScrollBar().maximum()
        )

    def on_done(self, success, msg):
        self.dl_btn.setEnabled(True)
        if success:
            self._exe_path = msg
            self.open_btn.setEnabled(True)
            self.status_lbl.setText(f"✅ สำเร็จ! → {msg}")
            self.append_log(f"\n📂 บันทึกไว้ที่:\n{msg}")
        else:
            self.status_lbl.setText("❌ ล้มเหลว — ดู log ด้านบน")
            self.append_log(f"\n❌ Error: {msg}")

    def open_folder(self):
        folder = os.path.dirname(self._exe_path)
        if os.path.exists(folder):
            os.startfile(folder)


def main():
    app = QApplication([])
    app.setStyleSheet(qdarkstyle.load_stylesheet(qt_api='pyqt5'))
    win = BuilderWindow()
    win.show()
    app.exec_()


if __name__ == "__main__":
    main()
