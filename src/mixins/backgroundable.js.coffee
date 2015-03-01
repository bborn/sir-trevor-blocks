# A SirTrevor mixin allowing any block to have an image as its background

define ['sir-trevor-js'], (SirTrevor)->

  SirTrevor.Block.prototype.availableMixins.push('backgroundable')

  SirTrevor.BlockMixins.Backgroundable = {

    mixinName: "Backgroundable"

    removeBackground: ()->
      @setData {file: null }
      @loadData @getData()

    editBackground: ()->
      @$inputs.toggle()

    initializeBackgroundable: ()->
      @controllable = true
      @droppable    = true
      @uploadable   = true

      @controls = {
        editBackground: @editBackground
      }

      input_html = $("<div>", { 'class': 'st-block__inputs' })

      @drop_options =
        html: ['<div class="st-block__dropzone">',
            '<span class="st-icon">image</span>',
            '<p><span>Drag background image here</span></p>',
            '<p><label class="st-input-label">Background Color</label>',
            '<input maxlength="140" name="background.color" class="st-input-string" type="text" /></p>'
            '<p><label class="st-input-label">Background Size</label>',
            '<input maxlength="140" name="background.size" class="st-input-string" type="text" /></p>'
            '<p><label class="st-input-label">Background Repeat</label>',
            '<input maxlength="140" name="background.repeat" class="st-input-string" type="text" /></p>'
            '<p><label class="st-input-label">Background Position</label>',
            '<input maxlength="140" name="background.position" class="st-input-string" type="text" /></p>'
            '</div>'].join('\n')



      @$inner.append(input_html)
      @$inputs = input_html

      @withMixin(SirTrevor.BlockMixins.Droppable)
      @withMixin(SirTrevor.BlockMixins.Uploadable)
      @withMixin(SirTrevor.BlockMixins.Controllable)

      #observe the background inputs for changes
      for input in @$inputs.find("[name^=background]")
        $(input).on 'change', ((ev)->
          @save()
          @loadData @getBlockData()
          @ready()
        ).bind(@)

      @$inputs.hide()
      @$editor.show()
      return

    backgroundImageUrl: (backgroundImage)->
      if backgroundImage
        return "url('#{backgroundImage}')"
      else
        return 'none'

    setBlockCss: (prefix, attr, val)->
      val = @backgroundImageUrl(val) if attr is 'image'
      @$inner.css {
        "#{prefix}#{attr}": val
      }

    loadData: (data)->
      @$editor.show()

      self = @ #coffeescript sets this inside the loop, not sure how to get around it

      #set the background css
      for attr, val of data.background

        do (attr, val)->
          self.setBlockCss('background-', attr, val)

          #set the input values
          self.$inputs.find("[name='background.#{attr}']").val(val)

          if val and attr is 'image' or 'color'
            self.getTextBlock().css({color: '#fff'})
          else
            self.getTextBlock().css({color: 'inherit'})

      #set the text
      @getTextBlock().html(SirTrevor.toHTML(data.text, @type)) if data.text

    onDrop: (transferData) ->
      file = transferData.files[0]
      urlAPI = if typeof URL != 'undefined' then URL else if typeof webkitURL != 'undefined' then webkitURL else null

      if /image/.test(file.type)
        @loading()

        @loadData
          background:
            image: urlAPI.createObjectURL(file)

        @uploader file, ((data) ->
          @setData {background: {image: data.file.url}}
          @ready()
          return
        ), (error) ->
          @addMessage i18n.t('blocks:image:upload_error')
          @ready()
          return
      return

    _serializeData: ()->
      data = {}

      # Override this to allow JSON-style nested attr names
      # uses .serializeObject() from https://github.com/macek/jquery-serialize-object

      if @hasTextBlock()
        data.text = @getTextBlockHTML()
        if data.text.length > 0 and @options.convertToMarkdown
          data.text = stToMarkdown(data.text, @type)

      # Add any inputs to the data attr
      if @$(':input').not('.st-paste-block').length > 0

        #get the background inputs
        data.background = @blockStorage.data.background || {}

        @$(':input[name^=background]').each (index, input) ->
          key = input.getAttribute('name').split('.')[1]
          data.background[key] = input.value

        #get the rest of the inputs
        @$(':input').not('[name^=background]').each (index, input) ->
          if input.getAttribute('name')
            data[input.getAttribute('name')] = input.value


        console.log data

      data


  }
