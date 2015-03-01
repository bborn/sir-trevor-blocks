# A SirTrevor mixin allowing any block to have an image as its background

define ['sir-trevor-js'], (SirTrevor)->

  SirTrevor.Block.prototype.availableMixins.push('backgroundable')

  SirTrevor.BlockMixins.Backgroundable = {

    mixinName: "Backgroundable"

    removeBackgroundImage: ()->
      @setData {file: null }
      @$inputs.hide()
      @loadData @getData()

    addBackgroundImage: ()->
      @toggleControls true
      @$inputs.show()

    initializeBackgroundable: ()->
      console.log 'test'
      @controllable = true
      @droppable    = true
      @uploadable   = true

      @controls = {
        removeImage: @removeBackgroundImage
        addImage: @addBackgroundImage
      }

      input_html = $("<div>", { 'class': 'st-block__inputs' })

      @drop_options =
        html: ['<div class="st-block__dropzone">',
            '<span class="st-icon">image</span>',
            '<p><span>Drag background image here</span>',
            '</p></div>'].join('\n')

      @$inner.append(input_html)
      @$inputs = input_html

      @withMixin(SirTrevor.BlockMixins.Droppable)
      @withMixin(SirTrevor.BlockMixins.Uploadable)
      @withMixin(SirTrevor.BlockMixins.Controllable)

      @$inputs.hide()
      @$editor.show()
      @toggleControls false
      return

    toggleControls: (background)->
      if background
        @$control_ui.find('a[data-icon=removeImage]').show()
        @$control_ui.find('a[data-icon=addImage]').hide()
      else
        @$control_ui.find('a[data-icon=removeImage]').hide()
        @$control_ui.find('a[data-icon=addImage]').show()

    hasBackground: ()->
      return @blockStorage.data.file and @blockStorage.data.file.url

    loadData: (data)->
      @$editor.show()
      if data.file and data.file.url
        @$inner.css({'background-image': "url('#{data.file.url}')", 'background-size' : 'cover' })
        @getTextBlock().css({color: '#fff'})
      else
        @$inner.css({'background-image': "none"})
        @getTextBlock().css({color: 'inherit'})

      @toggleControls(data.file and data.file.url)
      @getTextBlock().html(SirTrevor.toHTML(data.text, @type)) if data.text


    onDrop: (transferData) ->
      file = transferData.files[0]
      urlAPI = if typeof URL != 'undefined' then URL else if typeof webkitURL != 'undefined' then webkitURL else null

      if /image/.test(file.type)
        @loading()
        @$inputs.hide()
        @loadData file: url: urlAPI.createObjectURL(file)
        @uploader file, ((data) ->
          @setData data
          @ready()
          return
        ), (error) ->
          @addMessage i18n.t('blocks:image:upload_error')
          @ready()
          return
      return
  }
