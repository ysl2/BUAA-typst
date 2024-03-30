import os,re,subprocess,bs4,string

# judge the language of the string（cn or en）
remove_nota = u'[’·°–!"#$%&\'()*+,-./:;<=>?@，。?★、…【】（）《》？“”‘’！[\\]^_`{|}~]+'
remove_punctuation_map = dict((ord(char), None) for char in string.punctuation)
def filter_str(sentence):
    sentence = re.sub(remove_nota, '', sentence)
    sentence = sentence.translate(remove_punctuation_map)
    return sentence.strip()

def judge_lang(s):
    s = filter_str(s)
    result = []
    s = re.sub('[0-9]', '', s).strip()
    cnt_cn = cnt_en = 0
    for c in s:
        if c<='z':
            cnt_en+=1
        elif '\u4e00'<=c<='\u9fa5':
            cnt_cn+=1
    return 'cn' if cnt_cn > cnt_en else 'en'

# typfile = "mythesis.typ"
# typreffile = "chapters/reference.typ"
# bibfile = "chapters/reference.bib"
# settings
typfile = "thesis.typ"
bibfile = "ref.bib"
cslfile = "chinese-gb7714-2005-numeric.csl"
title = "Reference"
link_citations = "true"
tofile = True

typreffile = bibfile.split('.')[0]+'.typ'
mdfile = bibfile.split('.')[0]+'.md'
output = bibfile.split('.')[0]+'.html'

# Step 1: compile typst file
if not os.path.exists(typreffile):
    with open(typreffile,'w',encoding='utf-8') as f:
        pass

cmd_typst = r"./typst compile " + typfile
res = subprocess.run(cmd_typst,stdout=subprocess.PIPE,encoding='utf-8', shell=True).stdout

# write file to md
with open(mdfile,'w') as f:
    f.write(res)

# Step 2: use pandoc to gen reference
if tofile:
    cmd_tofile = "pandoc --citeproc " + mdfile + " --bibliography " + bibfile + " --csl " + cslfile + " --metadata title=\"" + title + "\" --metadata link-citations=" + link_citations + " -s -o " + output
    os.system(cmd_tofile)

cmd_pandoc = f"pandoc --citeproc {mdfile} --bibliography {bibfile} --csl {cslfile}"

res = subprocess.run(cmd_pandoc,stdout=subprocess.PIPE,encoding='utf-8', shell=True).stdout
soup = bs4.BeautifulSoup(res,features="html.parser")
refs = soup.find_all('div','csl-right-inline')
reflist = []
for idx,ref in enumerate(refs):
    # remove the \n
    content = re.sub('\n',' ',ref.text)
    lang = judge_lang(content)
    if lang == 'en':
        content = re.sub('等','et al',content)
        content = re.sub('卷','vol',content)
    print(f'[{idx+1}] {content}')
    reflist.append(content)

# Step 3: write to typst file
with open(typreffile,'w',encoding='utf-8') as f:
    for ref in reflist:
        f.write(f'+ {ref}\n\n')

# compile typst file again
subprocess.run(cmd_typst,stdout=subprocess.PIPE,encoding='utf-8', shell=True)
