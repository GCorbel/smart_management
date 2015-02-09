module SmartManagement
  module Helpers
    UNEDITABLE_COLUMNS = ['id', 'created_at', 'updated_at']

    def rest_manager_row(column_name)
      column = model_class.columns_hash[column_name]
      if column.sql_type == 'datetime'
        filter = " | date: 'dd-MM-yyyy hh:mm:ss'"
      end
      "{{row.resource.#{column.name} #{filter} }}"
    end

    def visible_columns
      model_class.column_names
    end

    def editable_columns
      model_class.column_names - UNEDITABLE_COLUMNS
    end

    def singular_model_name
      controller_name.to_s.singularize
    end

    def plural_model_name
      controller_name.to_s
    end

    def model_class
      singular_model_name.capitalize.camelize.constantize
    end

    def colspan
      model_class.columns.length + 2
    end

    def field_for(form:, klass:, column:)
      if klass.reflect_on_association(assoc_name(column))
        form.send(:association, assoc_name(column),
                  ng: { model: "editedResource.#{column}" } )
      else
        form.send(:input, column, ng: { model: "editedResource.#{column}" } )
      end
    end

    private

    def assoc_name(column)
      column.gsub(/_id$/, '')
    end
  end
end

ActionView::Base.send(:include, SmartManagement::Helpers) if defined?(ActionView::Base)