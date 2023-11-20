#import "functions/numbering.typ": *
#import "functions/outline.typ": *
#import "functions/style.typ": *
#import "functions/helpers.typ": *
#import "functions/underline.typ": *
#import "functions/codeblock.typ": *
#import "functions/figurelist.typ": *
#import "functions/booktab.typ": *

#import "info.typ": *
#import "custom.typ": *


#let conf(doc) = {
  set page("a4",
    // margin:
    header: locate(loc => {
      [
        #set text(字号.小五)
        #set align(center)
        
        #let flag = false
        #if partcounter.at(loc).at(0) == 10 {
          let footers = query(selector(<__footer__>).after(loc), loc)
          let elems = if footers != () { 
            query(heading.where(level: 1).before(footers.first().location()), footers.first().location())
          }
          if elems != () {
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
        #if query(selector(heading).before(loc), loc).len() < 1 or query(selector(heading).after(loc), loc).len() == 0 {
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

  set text(字号.小四, font: 字体.宋体, lang: "zh")
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
        #it.caption.body
      ]
    } else if it.kind == table {
      [
        #set text(字号.五号)
        表
        #locate(loc => {
          chinesenumbering(chaptercounter.at(loc).first(), tablecounter.at(loc).first(), location: loc)
        })
        #h(1em)
        #it.caption.body
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
        #it.caption.body
      ]
      it.body
    }
  ]

  show ref: it => {
    if it.element == none {
      // Keep citations as is
      it
    } else {
      // Remove prefix spacing
      h(0em, weak: true)

      let el = it.element
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
      }

      // Remove suffix spacing
      h(0em, weak: true)
    }
  }

  include "templates/cover.typ"

// 空白页
  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })
  pagebreak()
  
  include "templates/declaration.typ" 

  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })

  pagebreak()

  include "templates/abstract_cn.typ"
  
  locate(loc => {
    if alwaysstartodd {
      pagebreak()
    }
  })

  include "templates/abstract_en.typ"
  
  pagebreak()

  set align(left + top)
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

  
  par(justify: true, first-line-indent: 2em, leading: linespacing)[
    #doc
  ]

}
