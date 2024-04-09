#import "@preview/polylux:0.3.1": *

#let tsinghua = rgb("#82318E")

#let TITLE = state("title", [])
#let SUBTITLE = state("subtitle", [])
#let AUTHOR = state("author", [])
#let INSTITUTE = state("institute", [])

#let thu-polylux(
  aspect-ratio: "4-3",
  body
) = {
  set text(size: 24pt)

  set page(
    paper: "presentation-" + aspect-ratio,
    margin: (x: 0pt, top: 32pt, bottom: 40pt),

    header-ascent: 0pt,
    header: locate( loc => {
      let sections = utils.sections-state.final()
      let current = if utils.sections-state.at(here()).len() > 0 {
        utils.sections-state.at(here()).last().body
      } else {
        ""
      }
      let current_index = sections.position(section => section.body == current) + 0

      let section_pages = sections.map(section => section.loc.page())
      for (id, num) in section_pages.enumerate() {
        section_pages.at(id) = (num, section_pages.at(id + 1, default: counter(page).final().first()))
      }
      let current_page = counter(page).at(here()).first()
      let section_pages = section_pages.map(num_range => {
        let lo = num_range.first() + 1
        let hi = num_range.last() + 1
        stack(
          dir: ltr,
          spacing: 4pt,
          ..range(lo, hi).map(num => {
            link(
              (page: num, x: 0pt, y: 0pt),
              text(size: 8pt, stroke: 1pt + if num == current_page { white } else { white.darken(50%) })[○])
          })
        )
      })

      set text(size: 14pt, fill: white, font: "Noto Sans CJK SC")

      stack(
        dir: ttb,
        spacing: 0pt,
        block(
          fill: tsinghua.darken(40%),
          grid(
            rows: (20pt, 10pt),
            columns: sections.map(section => 1fr),
            align: center + horizon,
            // Link to each section
            ..sections.map(section => {
              set text(weight: if section.body == current { "bold" } else { "regular" })
              link(section.loc, section.body)
            }),
            // Link to each page
            ..section_pages
          )
        ),
        rect(
          width: 100%,
          height: 2pt,
          stroke: 0pt,
          fill: gradient.linear(
            (tsinghua.darken(40%), 0%),
            (tsinghua.darken(40%), (logic.logical-slide.at(here()).first() / logic.logical-slide.final().first()) * 100%),
            (tsinghua, 100%)
          )
        )
      )
    }),

    footer-descent: 0pt,
    footer: [
    #set text(font: "Noto Sans CJK SC", size: 16pt, fill: white)
      #grid(
        columns: (50%, 50%),
        rows: (20pt, 20pt),
        align: (left + horizon, right + horizon),
        fill: (x, y) => 
          if calc.even(y) { tsinghua }
          else { tsinghua.darken(40%) },
        inset: (x: 1.5em, y: 5pt),
        context AUTHOR.get(),
        context INSTITUTE.get(),
        context TITLE.get(),
        logic.logical-slide.display() + "  /  " + utils.last-slide-number
      )
    ]
  )

  set list(
    marker: ([•], [‣], [–]).map(marker => {
      set text(fill: tsinghua, size: 32pt)
      marker
    })
  )

  set enum(
    numbering: (num) => {
      circle(fill: tsinghua, radius: .5em)[
        #set align(center + horizon)
        #set text(fill: white)
        #num
      ]
    }
  )

  body
}

#let title-slide(
  title: [],
  subtitle: [],
  author: [],
  institute: [],
  date: datetime.today().display("[year]年[month padding:none]月[day padding:none]日")
) = {
  TITLE.update(title)
  SUBTITLE.update(subtitle)
  AUTHOR.update(author)
  INSTITUTE.update(institute)
  
  polylux-slide[
    #set align(center + horizon)
    #rect(fill: tsinghua, width: 80%, height: 4.5em)[
      #set text(fill: white, font: "Noto Sans CJK SC", size: 32pt, weight: "bold")
      
      #context { TITLE.get() }
      #v(-.5em)
      #context { SUBTITLE.get() }
    ]

    #set text(size: 24pt)
    #context { AUTHOR.get() }

    #set text(size: 16pt)
    #context { INSTITUTE.get() }

    #date

    #image("Tsinghua_University_Logo.svg", width: 5cm)
  ]
}

#let slide(
  title: [],
  body
) = {
  polylux-slide[
    #if title != [] {
      stack(
        dir: ttb,
        rect(fill: tsinghua, width: 100%, height: 40pt, inset: (x: 1em))[
          #set align(horizon)
          #set text(fill: white, font: "Noto Sans CJK SC", size: 32pt, weight: "bold")
          #title
        ],
        rect(width: 100%, height: 100% - 40pt, inset: 1.5em, stroke: 0pt)[
          #set align(horizon)
          #body 
        ]
      )
    } else {
      rect(width: 100%, height: 100%, inset: 1.5em, stroke: 0pt)[
        #set align(horizon)
        #body 
      ]
    }
    
  ]
}

#let tableofcontents(title: []) = {
  context {
    slide(title: title)[
      #let sections = utils.sections-state.final()

      #enum(
        ..sections.map(section => {
          set text(fill: tsinghua)
          link(section.loc, section.body)
        })
      )
    ]
  }
}

#let section(section-name, show-slide: false) = {
  utils.register-section(section-name)

  if show-slide [
    #context {
      let sections = utils.sections-state.final()
      let current = utils.sections-state.at(here()).last().body
      let current-index = sections.position(section => section.body == current)

      slide()[
        #show enum: it => {
          for (id, child) in it.children.enumerate() {
            block(
              pad(left: it.indent)[
                #stack(dir: ltr, spacing: it.body-indent)[
                  #circle(
                    fill: if id == current-index { tsinghua } else { tsinghua.lighten(50%) },
                    radius: .5em
                  )[
                    #set align(center + horizon)
                    #set text(fill: white)
                    #int(id + 1)
                  ]
                ][
                  #set text(if id == current-index { tsinghua } else { tsinghua.lighten(50%) })
                  #child.body
                ]
              ]
            )
          }
        }

        #enum(
          ..sections.map(section => {
            link(section.loc, section.body)
          })
        )
      ]
    }
  ]
}
