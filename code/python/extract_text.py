# -*- coding: utf-8 -*-
"""Extract text from the experiment .docx / .pptx files for reading."""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

from docx import Document
from pptx import Presentation

BASE = r"D:\脑与认知科学\第三次实验课"

def dump_docx(path):
    print("=" * 70)
    print("DOCX:", path)
    print("=" * 70)
    doc = Document(path)
    for p in doc.paragraphs:
        t = p.text.strip()
        if t:
            style = p.style.name if p.style is not None else ""
            print(f"[{style}] {t}")
    for ti, table in enumerate(doc.tables):
        print(f"--- TABLE {ti} ---")
        for row in table.rows:
            cells = [c.text.strip().replace("\n", " / ") for c in row.cells]
            print(" | ".join(cells))

def dump_pptx(path):
    print("=" * 70)
    print("PPTX:", path)
    print("=" * 70)
    prs = Presentation(path)
    for i, slide in enumerate(prs.slides, 1):
        print(f"\n----- SLIDE {i} -----")
        for shape in slide.shapes:
            if shape.has_text_frame:
                for para in shape.text_frame.paragraphs:
                    t = "".join(r.text for r in para.runs).strip()
                    if t:
                        print(t)
            if shape.has_table:
                for row in shape.table.rows:
                    print(" | ".join(c.text.strip() for c in row.cells))
        if slide.has_notes_slide:
            notes = slide.notes_slide.notes_text_frame.text.strip()
            if notes:
                print("[NOTES]", notes)

if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("all", "task"):
        dump_docx(BASE + r"\第三次实验任务书（脑电实验设计与时域分析）.docx")
    if what in ("all", "ppt"):
        dump_pptx(BASE + r"\第三次实验 (1)(1).pptx")
    if what in ("all", "tpl"):
        dump_docx(BASE + r"\第三次实验报告模板.docx")
