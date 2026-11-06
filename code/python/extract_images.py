# -*- coding: utf-8 -*-
"""Extract embedded images from the pptx (per slide) and the docx (word/media)."""
import io, os, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE
from docx import Document
import docx

BASE = r"D:\脑与认知科学\第三次实验课"
OUT = r"D:\脑与认知科学\_dsh_work\img"
os.makedirs(OUT, exist_ok=True)

# ---- pptx ----
prs = Presentation(BASE + r"\第三次实验 (1)(1).pptx")
n = 0
for i, slide in enumerate(prs.slides, 1):
    k = 0
    for shape in slide.shapes:
        if shape.shape_type == MSO_SHAPE_TYPE.PICTURE:
            k += 1
            img = shape.image
            ext = img.ext
            fn = os.path.join(OUT, f"slide{i:02d}_{k}.{ext}")
            with open(fn, "wb") as f:
                f.write(img.blob)
            w, h = img.size
            print(f"slide {i} pic{k} {ext} {w}x{h} -> {fn}")
            n += 1
print(f"PPT pictures: {n}")

# ---- docx ----
d = Document(BASE + r"\第三次实验任务书（脑电实验设计与时域分析）.docx")
m = 0
for rel in d.part.rels.values():
    if "image" in rel.reltype:
        m += 1
        ext = rel.target_part.partname.ext
        fn = os.path.join(OUT, f"docx_img{m}.{ext}")
        with open(fn, "wb") as f:
            f.write(rel.target_part.blob)
        print(f"docx media {m} {ext} -> {fn}")
print(f"DOCX images: {m}")
