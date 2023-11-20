#import "helpers.typ": *

#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 字体 = (
  仿宋: ("Times New Roman", "FangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
)

#let textit(it) = [
  #set text(font: 字体.楷体, style: "italic")
  #h(0em, weak: true)
  #it
  #h(0em, weak: true)
]

#let textbf(it) = [
  #set text(font: 字体.黑体, weight: "semibold")
  #h(0em, weak: true)
  #it
  #h(0em, weak: true)
]

#let lengthceil(len, unit: 字号.小四) = {
  let start = unit
  while start < len {
    start = start + unit
  }
  start
}

#let partcounter = counter("part")
#let chaptercounter = counter("chapter")
#let appendixcounter = counter("appendix")
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)
#let appendix() = {
  appendixcounter.update(10)
  chaptercounter.update(0)
  counter(heading).update(0)
}

#let chinesenumber(num, standalone: false) = if num < 11 {
  ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十").at(num)
} else if num < 100 {
  if calc.rem(num, 10) == 0 {
    chinesenumber(calc.floor(num / 10)) + "十"
  } else if num < 20 and standalone {
    "十" + chinesenumber(calc.rem(num, 10))
  } else {
    chinesenumber(calc.floor(num / 10)) + "十" + chinesenumber(calc.rem(num, 10))
  }
} else if num < 1000 {
  let left = chinesenumber(calc.floor(num / 100)) + "百"
  if calc.rem(num, 100) == 0 {
    left
  } else if calc.rem(num, 100) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 100))
  } else {
    left + chinesenumber(calc.rem(num, 100))
  }
} else {
  let left = chinesenumber(calc.floor(num / 1000)) + "千"
  if calc.rem(num, 1000) == 0 {
    left
  } else if calc.rem(num, 1000) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else if calc.rem(num, 1000) < 100 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else {
    left + chinesenumber(calc.rem(num, 1000))
  }
}

#let chinesenumbering(..nums, location: none, brackets: false) = locate(loc => {
  let actual_loc = if location == none { loc } else { location }
  if appendixcounter.at(actual_loc).first() < 10 {
    if nums.pos().len() == 1 {
      "第" + chinesenumber(nums.pos().first(), standalone: true) + "章"
    } else {
      numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
})

#let chineseunderline(s, width: 300pt, bold: false) = {
  let chars = s.split("")
  let n = chars.len()
  style(styles => {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt, styles).width > width or c == "\n" {
        if bold {
          ret.push(textbf(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(textbf(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%))
    }

    ret.join()
  })
}

#let chineseoutline(title: "目录", depth: none, indent: false) = {
  heading(title, numbering: none, outlined: false)
  locate(it => {
    let elements = query(heading.where(outlined: true).after(it), it)

    for el in elements {
      // Skip list of images and list of tables
      if partcounter.at(el.location()).first() < 20 and el.numbering == none { continue }

      // Skip headings that are too deep
      if depth != none and el.level > depth { continue }

      let maybe_number = if el.numbering != none {
        if el.numbering == chinesenumbering {
          chinesenumbering(..counter(heading).at(el.location()), location: el.location())
        } else {
          numbering(el.numbering, ..counter(heading).at(el.location()))
        }
        h(0.5em)
      }

      let line = {
        if indent {
          h(1em * (el.level - 1 ))
        }

        if el.level == 1 {
          v(0.5em, weak: true)
        }

        if maybe_number != none {
          style(styles => {
            let width = measure(maybe_number, styles).width
            box(
              width: lengthceil(width),
              link(el.location(),if el.level == 1 {
                textbf(maybe_number)
              } else {
                maybe_number
              })
            )
          })
        }

        link(el.location(),if el.level == 1 { // 适配分散对齐标题
          if el.body.has("children"){
            let body=el.body.children.filter(x => not x.has("amount")).join()
            textbf(body)
          }else{
            textbf(el.body)
          }
          
        } else {
          el.body
        })

        // Filler dots  // 北航模板不需要
        // if el.level == 1 {
        //   box(width: 1fr, h(10pt) + box(width: 1fr) + h(10pt))
        // } else {
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))
        // }

        // Page number
        let footer = query(selector(<__footer__>).after(el.location()), el.location())
        let page_number = if footer == () {
          0
        } else {
          counter(page).at(footer.first().location()).first()
        }
        link(el.location(),if el.level == 1 {
          textbf(str(page_number))
        } else {
          str(page_number)
        })

        linebreak()
        v(-0.2em)
      }

      line
    }
  })
}

#let listoffigures(title: "图目录", kind: image) = {
  heading(title, numbering: none, outlined: false)
  locate(it => {
    let elements = query(figure.where(kind: kind).after(it), it)

    for el in elements {
      let maybe_number = {
        let el_loc = el.location()
        chinesenumbering(chaptercounter.at(el_loc).first(), counter(figure.where(kind: kind)).at(el_loc).first(), location: el_loc)
        h(0.5em)
      }
      let line = {
        style(styles => {
          let width = measure(maybe_number, styles).width
          box(
            width: lengthceil(width),
            link(el.location(),maybe_number)
          )
        })

        link(el.location(),el.caption)

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footers = query(selector(<__footer__>).after(el.location()), el.location())
        let page_number = if footers == () {
          0
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(),str(page_number))
        linebreak()
        v(-0.2em)
      }

      line
    }
  })
}

#let codeblock(raw, caption: none, outline: false) = {
  figure(
    if outline {
      rect(width: 100%)[
        #set align(left)
        #raw
      ]
    } else {
      set align(left)
      raw
    },
    caption: caption, kind: "code", supplement: ""
  )
}

#let booktab(columns: (), aligns: (), width: auto, caption: none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())
  set align(center)

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let content_aligns = ()
  for i in range(0, contents.len()) {
    content_aligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  figure(
    block(
      width: width,
      grid(
        columns: (auto),
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..zip(headers, aligns).map(it => [
                #set align(it.last())
                #textbf(it.first())
              ])
            )
          )
        ],
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..zip(contents, content_aligns).map(it => [
                #set align(it.last())
                #it.first()
              ])
            )
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table
  )
}

#let strspacing(s,sz,fontsz) = {
  let chars = s.split("")
  chars = chars.slice(1,chars.len()-1)
  chars.join(h(fontsz))
}

#let strjustify(s,len,fontsz) = {
  let chars = s.split("")
  chars = chars.slice(1,chars.len()-1)
  let n = len - chars.len()
  let sz = n /(chars.len()-1)
  chars.join(h(sz*fontsz))
}

#let conf(
  cauthor: "张三",
  eauthor: "San Zhang",
  clcnumber: "O-1234567890",
  studentid: "23000xxxxx",
  cthesisname: "博士研究生学位论文",
  cheader: "北京航空航天大学博士学位论文",
  ctitle: "北京航空航天大学学位论文Typst模板",
  etitle: "Typst Template for Beihang University Dissertations",
  cschool: "某个学院",
  eschool: "Some School",
  cmajor: "某个专业",
  emajor: "Some Major",
  direction: "某个研究方向",
  csupervisor: "李四",
  esupervisor: "Si Li",
  supervisortitle: "教授",
  date: "二零二三年六月",
  cabstract: "这是中文摘要",
  ckeywords: ("关键词1", "关键词2"),
  eabstract: "This is English abstract",
  ekeywords: ("keyword1", "keyword2"),
  acknowledgements: [],
  linespacing: 1.5em,
  outlinedepth: 3,
  blind: false,
  listofimage: true,
  listoftable: true,
  listofcode: true,
  alwaysstartodd: true,
  doc,
) = {
  set page("a4",
    // margin:
    header: locate(loc => {
      [
        #set text(字号.小五)
        #set align(center)
        
        // #if partcounter.at(loc).at(0) < 10 {
          // Handle the first page of Chinese abstract specailly
          // let headings = query(selector(heading).after(loc), loc)
          // let next_heading = if headings == () {
          //   ()
          // } else {
          //   headings.first().body.text
          // }
          // if next_heading == "摘要" and calc.odd(loc.page()) {
          //   [
          //     摘要
          //     #v(-0.7em)
          //     #line(length: 100%,stroke: 0.5pt)
          //   ]
          // }
        // } else if partcounter.at(loc).at(0) > 20 {
        // } else {
        #let flag = false
        #if partcounter.at(loc).at(0) == 10 {
          let footers = query(selector(<__footer__>).after(loc), loc)
          let elems = if footers != () { 
            query(heading.where(level: 1).before(footers.first().location()), footers.first().location())
          }
          if elems != none {
            flag = elems.last().numbering==chinesenumbering
          }
        }
        #if partcounter.at(loc).at(0) == 20{
          flag = true
        }
        #if flag{
          if calc.even(loc.page()) {
            [
              #align(center, cheader)
              #v(-1em)
              #line(length: 100%,stroke: 0.5pt)
            ]
          } else {
            let footers = query(selector(<__footer__>).after(loc), loc)
            let elems = if footers != () {
              query(
                heading.where(level: 1).before(footers.first().location()), footers.first().location()
              )
            }
            if elems != none {
              let el = elems.last()
              [
                #let numbering = if el.numbering == chinesenumbering {
                  chinesenumbering(..counter(heading).at(el.location()), location: el.location())
                } else if el.numbering != none {
                  numbering(el.numbering, ..counter(heading).at(el.location()))
                }
                #if numbering != none {
                  numbering
                  h(0.5em)
                }
                // 适配分散对齐标题
                #if not el.body.has("text"){
                  el.body.children.filter(x => not x.has("amount")).join()
                }else{
                  el.body
                }
                
                #v(-1em)
                #line(length: 100%,stroke: 0.5pt)
              ]
            }
          }
      }]}),
    footer: locate(loc => {
      [
        #set text(字号.五号)
        #set align(center)   
        // 北航从摘要页开始
        #if query(selector(heading).before(loc), loc).len() < 5 or query(selector(heading).after(loc), loc).len() == 0 {
          // Skip cover, copyright and origin pages
        } else {
          let headers = query(selector(heading).before(loc), loc)
          let part = partcounter.at(headers.last().location()).first()
          [
            #if part < 20 {
              numbering("I", counter(page).at(loc).first())
            } else {
              str(counter(page).at(loc).first())
            }
          ]
        }
        #label("__footer__")
      ]
    }),
  )

  set text(字号.一号, font: 字体.宋体, lang: "zh")
  set align(center + horizon)
  set heading(numbering: chinesenumbering)
  set figure(
    numbering: (..nums) => locate(loc => {
      if appendixcounter.at(loc).first() < 10 {
        numbering("1.1", chaptercounter.at(loc).first(), ..nums)
      } else {
        numbering("A.1", chaptercounter.at(loc).first(), ..nums)
      }
    })
  )
  set math.equation(
    numbering: (..nums) => locate(loc => {
      set text(font: 字体.宋体)
      if appendixcounter.at(loc).first() < 10 {
        numbering("(1.1)", chaptercounter.at(loc).first(), ..nums)
      } else {
        numbering("(A.1)", chaptercounter.at(loc).first(), ..nums)
      }
    })
  )
  set list(indent: 2em)
  set enum(indent: 2em)

  show strong: it => textbf(it)
  show emph: it => textit(it)
  show par: set block(spacing: linespacing)
  show raw: set text(font: 字体.代码)

  show heading: it => [
    // Cancel indentation for headings of level 2 or above
    #set par(first-line-indent: 0em)

    #let sizedheading(it, size) = [
      #set text(size)
      #v(0.5*size)
      #if it.numbering != none {
        textbf(counter(heading).display())
        h(0.5em)
      }
      #textbf(it.body)
      #v(0.5*size)
    ]

    #if it.level == 1 {
      // pagebreak(weak: true)
      if it.body.has("text") and not it.body.text in ("Abstract")  {
          pagebreak(weak: true)
      }
      locate(loc => {
        // 适配分散对齐标题
        let content = ""
        if it.body.has("children"){
          content = it.body.children.at(0).text+it.body.children.at(2).text
        }else if it.body.has("text"){
          content = it.body.text
        }
        if content == "摘要"{
          partcounter.update(10)
          counter(page).update(1)
        } else if it.numbering != none and partcounter.at(loc).first() < 20 {
          partcounter.update(20)
          counter(page).update(1)
        }
      })
      if it.numbering != none {
        chaptercounter.step()
      }
      imagecounter.update(())
      tablecounter.update(())
      rawcounter.update(0)
      equationcounter.update(())

      set align(center)
      sizedheading(it, 字号.三号)
    } else {
      if it.level == 2 {
        sizedheading(it, 字号.四号)
      } else if it.level == 3 {
        sizedheading(it, 字号.中四)
      } else {
        sizedheading(it, 字号.小四)
      }
    }
  ]

  show figure: it => [
    #set align(center)
    #if not it.has("kind") {
      it
    } else if it.kind == image {
      it.body
      [
        #set text(字号.五号)
        图
        #locate(loc => {
          chinesenumbering(chaptercounter.at(loc).first(), imagecounter.at(loc).first(), location: loc)
        })
        #h(1em)
        #it.caption
      ]
    } else if it.kind == table {
      [
        #set text(字号.五号)
        表
        #locate(loc => {
          chinesenumbering(chaptercounter.at(loc).first(), tablecounter.at(loc).first(), location: loc)
        })
        #h(1em)
        #it.caption
      ]
      it.body
    } else if it.kind == "code" {
      [
        #set text(字号.五号)
        代码
        #locate(loc => {
          chinesenumbering(chaptercounter.at(loc).first(), rawcounter.at(loc).first(), location: loc)
        })
        #h(1em)
        #it.caption
      ]
      it.body
    }
  ]

  show ref: it => {
    locate(loc => {
      let elems = query(it.target, loc)

      if elems == () {
        // Keep citations as is
        it
      } else {
        // Remove prefix spacing
        h(0em, weak: true)

        let el = elems.first()
        let el_loc = el.location()
        if el.func() == math.equation {
          // Handle equations
          link(el_loc, [
            式
            #chinesenumbering(chaptercounter.at(el_loc).first(), equationcounter.at(el_loc).first(), location: el_loc, brackets: true)
          ])
        } else if el.func() == figure {
          // Handle figures
          if el.kind == image {
            link(el_loc, [
              图
              #chinesenumbering(chaptercounter.at(el_loc).first(), imagecounter.at(el_loc).first(), location: el_loc)
            ])
          } else if el.kind == table {
            link(el_loc, [
              表
              #chinesenumbering(chaptercounter.at(el_loc).first(), tablecounter.at(el_loc).first(), location: el_loc)
            ])
          } else if el.kind == "code" {
            link(el_loc, [
              代码
              #chinesenumbering(chaptercounter.at(el_loc).first(), rawcounter.at(el_loc).first(), location: el_loc)
            ])
          }
        } else if el.func() == heading {
          // Handle headings
          if el.level == 1 {
            link(el_loc, chinesenumbering(..counter(heading).at(el_loc), location: el_loc))
          } else {
            link(el_loc, [
              节
              #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
            ])
          }
        } else {
          // Handle code blocks
          // Since the ref is linked to the code block instead of the internal
          // `figure`, we need to do an extra query here.
          let figure_el = query(selector(figure).after(el_loc), el_loc).first()
          let el_loc = figure_el.location()
          link(el_loc, [
            #if figure_el.kind == image {
              [图]
            } else if figure_el.kind == table {
              [表]
            } else if figure_el.kind == "code" {
              [代码]
            }
            #chinesenumbering(
              chaptercounter.at(el_loc).first(),
              counter(figure.where(kind: figure_el.kind)).at(el_loc).first(), location: el_loc
           )]
          )
        }

        // Remove suffix spacing
        h(0em, weak: true)
      }
    })
  }

// 首页
  heading(numbering: none, outlined: false, "")
  v(-80pt)
  set text(字号.五号,font: 字体.黑体)
  set align(left)
  grid(
    columns: (6*字号.五号,auto),
    row-gutter: 1.5em,
    textbf("中图分类号："),
    textbf(clcnumber),
    textbf(strjustify("论文编号",5,字号.五号)+"："),
    textbf("10006"+studentid)
  )
  v(100pt)
  set align(center)
  grid(
      columns: (auto),
      gutter: 1.5em,
      image("logo-buaa.svg", width: 70%, fit: "contain"),
      image("head-doctor.png", width: 90%, fit: "contain")
  )

  v(20pt)
  set text(字号.小初,font:字体.宋体)
  set align(center + horizon)

  ctitle

  v(60pt)
  set text(字号.小三)

  let fieldname(name) = [
    #set align(right + horizon)
    #textbf(strjustify(name,5,字号.小三))
  ]

  let fieldvalue(value) = [
    #set align(left + horizon)
    #textbf(value)
  ]

  grid(
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
  pagebreak()

// 空白页
  if alwaysstartodd {
    pagebreak()
  }


// 英文首页
  set align(center + top)
  set text(字号.小二)
  heading(numbering: none, outlined: false, "")
  v(100pt)
  textbf(etitle)
  v(50pt)
  set text(字号.四号)
  "A Dissertation Submitted for the Degree of Doctor of Philosophy"
  v(100pt)
  set text(字号.小三)
  grid(
    columns:(70pt,auto),
    row-gutter: 1.5em,
    column-gutter: 1em,
    textbf("Candidate :"), fieldvalue(eauthor),
    textbf("Supervisor:"), fieldvalue("Prof. "+esupervisor)
  )
  v(130pt)
  eschool
  linebreak()
  v(0.5em)
  "Beihang University, Beijing, China"
  pagebreak()
  
// 空白页
  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })

// 中文首页
  heading(numbering: none, outlined: false, "")
  set text(字号.五号,font: 字体.黑体)
  set align(left)
  v(-20pt)
  grid(
    columns: (6*字号.五号,auto),
    row-gutter: 1.5em,
    textbf("中图分类号："),
    textbf(clcnumber),
    textbf(strjustify("论文编号",5,字号.五号)+"："),
    textbf("10006"+studentid)
  )
  v(130pt)
  set align(center)
  set text(字号.小二)
  strjustify(cthesisname,11,字号.小二)
  v(50pt)
  set text(字号.小一)
  ctitle
  v(110pt)
  
  let gridval(value) = [
    #set align(left + horizon)
    #value
  ]
  
  set text(字号.小四,font: 字体.宋体)
  grid(
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
  
// 空白页
  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })
  
  set align(center)
  heading(numbering: none, outlined: false, "关于学位论文的独创性声明")
  set align(start)
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
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
  v(50pt)
  set align(center)
  set text(字号.三号,font: 字体.黑体)
  "学位论文使用授权"
  v(0.5em)
  set align(start)
  set text(字号.小四,font: 字体.宋体)
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
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

  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })

  pagebreak()
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
    #heading(strjustify("摘要",3,字号.三号),numbering: none, outlined: false)
    #let paras = cabstract.split("\r\n")  // 支持多行摘要，TODO：改为content
    #for p in paras {
      p
      v(0em)
    }

    *关键词：*
    #ckeywords.join("，")
    #v(2em)
  ]
 locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
      #heading(numbering: none, outlined: false, "Abstract")
      #let paras = eabstract.split("\r\n")
      #for p in paras {
        p
        v(0em)
      }

      *Key words:*
      #h(0.5em, weak: true)
      #ekeywords.join(", ")
      #v(2em)
    ]
  
  pagebreak()

  locate(loc => {
    if alwaysstartodd and calc.even(loc.page()) {
      pagebreak()
    }

    chineseoutline(
      title: strjustify("目录",3,字号.三号),
      depth: outlinedepth,
      indent: true,
    )
  })

  if listofimage {
    listoffigures(title: "图清单")
  }

  if listoftable {
    listoffigures(title: "表清单", kind: table)
  }

  if listofcode {
    listoffigures(title: "代码", kind: "code")
  }

  set align(left + top)
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
    #doc
  ]

}
