module GrdaWarehouse
  class AvailableFileTag < GrdaWarehouseBase
    include DefaultFileTypes

    scope :ordered, -> do 
      order(weight: :asc, group: :asc, name: :asc)
    end

    scope :consent_forms, -> do
      where(consent_form: true)
    end

    scope :full_release, -> do
      consent_forms.where(full_release: true)
    end

    scope :partial_consent, -> do
      consent_forms.where(full_release: false)
    end

    scope :document_ready, -> do
      where(document_ready: true)
    end

    scope :notification_triggers, -> do
      where(notification_trigger: true)
    end

    def self.contains_consent_form?(tag_names=[])
      consent_forms.where(name: tag_names).exists?
    end

    def self.full_release?(tag_names=[])
      full_release.where(name: tag_names).exists?
    end

    def self.partial_consent?(tag_names=[])
      partial_consent.where(name: tag_names).exists?
    end

    def self.should_send_notifications?(tag_names=[])
      notification_triggers.where(name: tag_names).exists?
    end

    def self.grouped
      groups = []

      self.ordered.group_by{|tag| tag.group}
    end

    # Taken from here:https://github.com/carrierwaveuploader/carrierwave-i18n/blob/master/rails/locales/en.yml
    # These don't get translated appropriately unless they are here
    # def translations
    #   _("failed to be processed")
    #   _("is not of an allowed file type")
    #   _("could not be downloaded")
    #   _("You are not allowed to upload %{extension} files, allowed types: %{allowed_types}")
    #   _("You are not allowed to upload %{extension} files, prohibited types: %{prohibited_types}")
    #   _("You are not allowed to upload %{content_type} files")
    #   _("You are not allowed to upload %{content_type} files")
    #   _("Failed to manipulate with rmagick, maybe it is not an image?")
    #   _("Failed to manipulate with MiniMagick, maybe it is not an image? Original Error: %{e}")
    #   _("File size should be greater than %{min_size}")
    #   _("File size should be less than %{max_size}")
    # end
  end
end
