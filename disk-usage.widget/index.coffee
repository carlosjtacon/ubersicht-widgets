# You may exclude certain drives (separate with a pipe)
# Example: exclude = 'MyBook' or exclude = 'MyBook|WD Passport'
# Set as something obscure to show all drives (strange, but easier than editing the command)
# exclude   = 'NONE'
exclude   = 'recovery|vm'

# Use base 10 numbers, i.e. 1GB = 1000MB. Leave this true to show disk sizes as
# OS X would (since Snow Leopard)
base10       = true

# appearance
filledStyle  = true # set to true for the second style variant. bgColor will become the text color

width        = '370px'
barHeight    = '50px'
labelColor   = '#fff'
usedColor    = 'rgba(#fff, 0.2)'
freeColor    = 'rgba(#fff, 0.1)'
bgColor      = '#fff'
borderRadius = '0px'
bgOpacity    = 0.1

# You may optionally limit the number of disk to show
maxDisks: 10


command: "df -#{if base10 then 'H' else 'h'}  | grep -vE '#{exclude}' | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done"

refreshFrequency: 60000

style: """
  top: 160px
  left: 20px
  font-family: Helvetica Neue
  font-weight: 200

  .label
    font-size: 11px
    color: #{labelColor}
    margin-left: 0px
    font-weight: bold
    font-family: Helvetica Neue

    .total
      display: inline-block
      margin-left: 5px
      font-weight: bold

  .disk:not(:first-child)
    margin-top: 16px

  .wrapper
    height: #{barHeight}
    font-size: #{Math.round(parseInt(barHeight)*0.8)}px
    line-height: 1
    width: #{width}
    max-width: #{width}
    margin: 2px 0 0 0
    position: relative
    overflow: hidden
    border-radius: #{borderRadius}
    border: 1px solid #fff
    background: rgba(#{bgColor}, #{bgOpacity})
    #{'background: none' if filledStyle }

  .wrapper:first-of-type
    margin: 0px

  .bar
    position: absolute
    top: 0
    bottom: 0px

    &.used
      border-radius: #{borderRadius} 0 0 #{borderRadius}
      background: #{usedColor}
      border: 1px solid #{usedColor}
      #{'border-bottom: none' if filledStyle }

    &.free
      right: 0
      border-radius: 0 #{borderRadius} #{borderRadius} 0
      background: #{freeColor}
      border-bottom:  1px solid #{freeColor}
      #{'border-bottom: none' if filledStyle }


  .stats
    display: inline-block
    font-size: 0.5em
    line-height: 1
    word-spacing: -2px
    text-overflow: ellipsis
    vertical-align: middle
    position: relative

    span
      font-size: 0.8em
      margin-left: 2px

    .free, .used
      display: inline-block
      white-space: nowrap


    .free
      margin-left: 12px
      color: #{if filledStyle then bgColor else freeColor}

    .used
      color: #{if filledStyle then bgColor else usedColor}
      margin-left: 6px
      font-size: 0.9em

  .needle
    width: 0
    border-left: 1px dashed rgba(#{usedColor}, 0.2)
    position: absolute
    top: 0
    bottom: -2px
    display: #{'none' if filledStyle}

    &:after, &:before
      content: ' '
      border-top: 5px solid #{usedColor}
      border-left: 4px solid transparent
      border-right: 4px solid transparent
      position: absolute
      left: -4px
"""

humanize: (sizeString) ->
  sizeString + 'B'


renderInfo: (total, used, free, pctg, name) -> """
  <div class='disk'>
    <div class='label'>#{name.toLowerCase()}</span></div>
    <div class='wrapper'>
      <div class='bar used' style='width: #{pctg}'></div>
      <div class='bar free' style='width: #{100 - parseInt(pctg)}%'></div>

      <div class='stats'>
        <div class='free'>#{@humanize(free).toLowerCase()} <span>free</span> </div>
        <div class='used'>#{@humanize(used).toLowerCase()} <span>used</span></div>
      </div>
      <div class='needle' style="left: #{pctg}"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  disks = output.split('\n')
  $(domEl).html ''

  for disk, i in disks[..(@maxDisks - 1)]
    args = disk.split(' ')
    if (args[4])
      args[4] = args[4..].join(' ')
      $(domEl).append @renderInfo(args...)
