# frozen_string_literal: true

# The ComponentsHelper module provides helper methods for generating links with various options.
module ComponentsHelper
  # Generates a link with the given URL and options.
  #
  # @param url [String] The URL for the link.
  # @param opts [Hash] The options for the link.
  # @option opts [String] :class_name The CSS class for the link.
  # @option opts [Boolean] :remote Whether the link should be remote or not.
  # @option opts [String] :title The title for the link.
  # @option opts [String] :icon The icon for the link.
  # @return [String] The generated link.
  def link(url, opts = {})
    link_to url, id: opts[:id], class: opts[:class_name] || 'btn btn-sm btn-primary',
                 remote: opts[:remote] || true,
                 data: {
                   bs_toggle: 'tooltip',
                   bs_title: opts[:title]
                 } do
      opts[:icon] ? fa_icon(opts[:icon]) : opts[:title]
    end
  end

  # Generates a new link with the given URL.
  #
  # @param url [String] The URL for the link.
  # @return [String] The generated new link.
  def link_new(url)
    link(url,
         { id: 'new-todo', title: translate_link('new', model: translate_model(Todo)),
           class_name: 'btn btn-sm btn-primary', data: { remote: true } })
  end

  # Generates a show link with the given URL.
  #
  # @param url [String] The URL for the link.
  # @return [String] The generated show link.
  def link_show(url)
    link(url,
         { id: 'show-todo', icon: 'eye', title: translate_link('show'),
           class_name: 'btn btn-sm btn-info dropdown-item' })
  end

  # Generates an edit link with the given URL.
  #
  # @param url [String] The URL for the link.
  # @return [String] The generated edit link.
  def link_edit(url)
    link(url, { id: 'edit-todo', icon: 'edit', title: translate_link('edit'), class_name: 'btn btn-sm btn-success' })
  end

  # Generates a confirm delete link with the given URL.
  #
  # @param url [String] The URL for the link.
  # @return [String] The generated confirm delete link.
  def link_confirm_delete(url)
    link(url,
         { id: 'confirm-delete-todo',
           icon: 'trash',
           title: translate_link('confirm_delete'),
           class_name: 'btn btn-sm btn-danger',
           remote: true })
  end

  def link_sort(url, opts = {})
    link_to fa_icon(opts[:icon]), url, class: 'd-block', remote: opts[:remote] || true,
                                       disabled: opts[:disabled] || false
  end

  def link_edit_inline(url, title)
    link_to(
      title,
      url,
      id: 'inline-todo',
      class: 'text-decoration-none text-block mt-2',
      remote: true,
      data: { bs_toggle: 'tooltip', bs_title: translate_link('edit') }
    )
  end

  def close_modal_button(title)
    button_tag title, type: 'button', class: 'btn btn-danger', data: { bs_dismiss: 'modal' }
  end

  def submit_button(form, delete: false)
    title = case delete
    when true
              :delete
    else
              form.object.new_record? ? :new : :edit
    end

    form.submit translate_btn(form.object.class, title), class: 'btn btn-primary', data: { bs_dismiss: 'modal', remote: true }
  end
end
