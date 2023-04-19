#import "../functions/style.typ": *
#import "../functions/helpers.typ": *
#import "../custom.typ": *
#import "../info.typ": *

// 首页
#set align(center + top)
// #v(-80pt)
#set text(字号.五号,font: 字体.黑体)
#set align(left)
#grid(
    columns: (6*字号.五号,auto),
    row-gutter: 1.5em,
    textbf("中图分类号："),
    textbf(clcnumber),
    textbf(strjustify("论文编号",5,字号.五号)+"："),
    textbf("10006"+studentid)
)
#v(100pt)
#set align(center)
#grid(
    columns: (auto),
    gutter: 1.5em,
    image("../logo-buaa.svg", width: 70%, fit: "contain"),
    image("../head-doctor.png", width: 90%, fit: "contain")
)

#v(20pt)
#set text(字号.小初,font:字体.宋体)
#set align(center + horizon)

#ctitle

#v(60pt)
#set text(字号.小三)

#let fieldname(name) = [
    #set align(right + horizon)
    #textbf(strjustify(name,5,字号.小三))
]

#let fieldvalue(value) = [
    #set align(left + horizon)
    #textbf(value)
]

#grid(
    columns: (100pt, 180pt),
    row-gutter: 1.5em,
    column-gutter: 1.5em,
    fieldname("作者姓名"),
    fieldvalue(cauthor),
    fieldname("学科专业"),
    fieldvalue(cmajor),
    fieldname("指导教师"),
    fieldvalue(csupervisor+h(1em)+"教"+h(0.3em)+"授"),
    fieldname("培养院系"),
    fieldvalue(cschool),
)
#pagebreak()

// 空白页
#if alwaysstartodd {
    pagebreak()
}


// 英文首页
#set align(center + top)
#set text(字号.小二)

#v(100pt)
#textbf(etitle)
#v(50pt)
#set text(字号.四号)
A Dissertation Submitted for the Degree of Doctor of Philosophy
#v(100pt)
#set text(字号.小三)
#grid(
    columns:(70pt,auto),
    row-gutter: 1.5em,
    column-gutter: 1em,
    textbf("Candidate :"), fieldvalue(eauthor),
    textbf("Supervisor:"), fieldvalue("Prof. "+esupervisor)
)
#v(130pt)
#eschool
#linebreak()
#v(0.5em)
Beihang University, Beijing, China
#pagebreak()

// 空白页
#locate(loc => {
if alwaysstartodd {
    pagebreak()
}
})

// 中文首页

#set text(字号.五号,font: 字体.黑体)
#set align(left)
#grid(
    columns: (6*字号.五号,auto),
    row-gutter: 1.5em,
    textbf("中图分类号："),
    textbf(clcnumber),
    textbf(strjustify("论文编号",5,字号.五号)+"："),
    textbf("10006"+studentid)
)
#v(130pt)
#set align(center)
#set text(字号.小二)
#strjustify(cthesisname,11,字号.小二)
#v(50pt)
#set text(字号.小一)
#ctitle
#v(110pt)

#let gridval(value) = [
    #set align(left + horizon)
    #value
]

#set text(字号.小四,font: 字体.宋体)
#grid(
    columns:(1fr,1.5fr,1fr,1.5fr),
    row-gutter: 2em,
    gridval("作者姓名"),gridval(cauthor),
    gridval("申请学位级别"), gridval("全日制工学博士"),
    gridval("指导教师姓名"),gridval(csupervisor),
    gridval(strjustify("职称",4,字号.小四)),gridval(supervisortitle),
    gridval("学科专业"),gridval(cmajor),
    gridval("研究方向"),gridval(direction),
    gridval("学习时间自"),gridval("      年      月      日"),
    gridval(h(2*字号.小四)+"起至"),gridval("      年      月      日止"),
    gridval("论文提交日期"),gridval("      年      月      日"),
    gridval("论文答辩日期"),gridval("      年      月      日"),
    gridval("学位授予单位"),gridval("北京航空航天大学"),
    gridval("学位授予日期"),gridval("      年      月      日"),
)