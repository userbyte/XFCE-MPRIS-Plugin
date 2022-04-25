from PIL import Image
from resizeimage import resizeimage
import sys, os, wget
try:
    workingdir = str(sys.argv[1])
    url = str(sys.argv[2])
    size = int(sys.argv[3])
except IndexError:
    raise Exception("missing arguments")
os.chdir(workingdir)

if os.path.exists('./prevArtUrl.txt'):
    with open('./prevArtUrl.txt') as uf:
        prevurl = uf.read()
    if prevurl == url:
        print('URL is the same, skipping redownload and resize.')
        exit()
try:
    os.remove('./img.png')
    os.remove('./out.png')
except Exception as e:
    pass

wget.download(url, './img.png')

with open('./img.png', 'r+b') as f:
    with Image.open(f) as image:
        cover = resizeimage.resize_height(image, size)
        cover.save('./out.png', image.format)

with open('./prevArtUrl.txt', 'w') as uf:
    uf.write(url)