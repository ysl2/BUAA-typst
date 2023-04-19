#import "../functions/style.typ": *
#import "../custom.typ": *

#set align(center+top)
#set text(字号.三号,font: 字体.黑体)
// #heading(numbering: none, outlined: false, "关于学位论文的独创性声明")
关于学位论文的独创性声明
#set align(start)
#set text(字号.小四,font: 字体.宋体)
#par(justify: true, first-line-indent: 2em, leading: linespacing)[
    本人郑重声明：所呈交的论文是本人在指导教师指导下独立进行研究工作所取得的
    成果，论文中有关资料和数据是实事求是的。尽我所知，除文中已经加以标注和致谢外，
    本论文不包含其他人已经发表或撰写的研究成果，也不包含本人或他人为获得北京航空
    航天大学或其它教育机构的学位或学历证书而使用过的材料。与我一同工作的同志对研
    究所做的任何贡献均已在论文中作出了明确的说明。

    若有不实之处，本人愿意承担相关法律责任。 

    \
    #set text(字号.五号)
    #h(2em)学位论文作者签名：#h(15em) #"日期：,年,月,日".split(",").join(h(2em))
    #v(-1.5em)
    #line(start:(25%,0%),stroke:0.5pt,length:25%)
]
#v(50pt)
#set align(center)
#set text(字号.三号,font: 字体.黑体)
学位论文使用授权
#v(0.5em)
#set align(start)
#set text(字号.小四,font: 字体.宋体)
#par(justify: true, first-line-indent: 2em, leading: linespacing)[
    本人完全同意北京航空航天大学有权使用本学位论文（包括但不限于其印刷版和电
    子版），使用方式包括但不限于：保留学位论文，按规定向国家有关部门（机构）送交学
    位论文，以学术交流为目的赠送和交换学位论文，允许学位论文被查阅、借阅和复印，
    将学位论文的全部或部分内容编入有关数据库进行检索，采用影印、缩印或其他复制手
    段保存学位论文。

    保密学位论文在解密后的使用授权同上。 

    \
    #set text(字号.五号)
    #h(2em)学位论文作者签名：#h(15em) #"日期：,年,月,日".split(",").join(h(2em))
    #v(-1.5em)
    #line(start:(25%,0%),stroke:0.5pt,length:25%)
    #h(2em)指导教师签名：#h(2*字号.五号)#h(15em) #"日期：,年,月,日".split(",").join(h(2em))
    #v(-1.5em)
    #line(start:(20%,0%),stroke:0.5pt,length:30%)
]