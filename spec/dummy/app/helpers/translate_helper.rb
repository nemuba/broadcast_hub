# frozen_string_literal: true

# The TranslateHelper module provides helper methods for translating model names, attributes, enums, and buttons.
module TranslateHelper
  # Translates the given model name.
  #
  # @param model [ActiveRecord::Base] The model to translate.
  # @return [String] The translated model name.
  def translate_model(model)
    model.model_name.human
  end

  # Translates the given attribute of a model.
  #
  # @param model [ActiveRecord::Base] The model containing the attribute.
  # @param attribute [Symbol] The attribute to translate.
  # @return [String] The translated attribute name.
  def translate_attribute(model, attribute)
    model.human_attribute_name(attribute)
  end

  # Translates the given enum value of a model attribute.
  #
  # @param model [ActiveRecord::Base] The model containing the attribute.
  # @param attribute [Symbol] The attribute containing the enum.
  # @param value [Symbol] The enum value to translate.
  # @return [String] The translated enum value.
  def translate_enum(model, attribute, value)
    model.human_enum_name(attribute, value)
  end

  # Translates the button text for the given model and action.
  #
  # @param model [ActiveRecord::Base] The model associated with the button.
  # @param action [Symbol] The action associated with the button.
  # @return [String] The translated button text.
  def translate_btn(model, action)
    I18n.t("helpers.submit.#{action}", model: translate_model(model))
  end

  # Translates the links text for the given model and action.
  #
  # @param model [ActiveRecord::Base] The model associated with the button.
  # @param action [Symbol] The action associated with the button.
  # @return [String] The translated button text.
  def translate_link(action, **options)
    I18n.t("helpers.links.#{action}", **options)
  end
end
