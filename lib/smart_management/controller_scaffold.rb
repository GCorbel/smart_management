module SmartManagement
  module ControllerScaffold
    include SmartManagement::Helpers

    def index
      respond_to do |format|
        format.html { render 'index' }
        format.json { render json: json_values }
      end
    end

    def show
      respond_with(resource)
    end

    def create
      resource.save if resource.valid?
    end

    def update
      resource.save if resource.valid?
    end

    def destroy
      resource.destroy
      respond_with(resource)
    end

    private

    def resource_attributes
      params.require(singular_model_name.to_sym).permit(editable_columns_syms)
    end

    def editable_columns_syms
      editable_columns.map do |column|
        column.name.to_sym
      end
    end

    def sort_options
      JSON.parse(params["sort"]).symbolize_keys if params["sort"]
    end

    def pagination_options
      JSON.parse(params["pagination"]).symbolize_keys if params["pagination"]
    end

    def search_options
      if params["search"]
        search_params = JSON.parse(params["search"])
        if search_params["predicateObject"]
          search_params["predicateObject"].symbolize_keys
        end
      end
    end

    def smart_management_options
      { sort: sort_options, pagination: pagination_options, search: search_options }
    end

    private

    def self.included(controller)
      controller.decent_configuration do
        strategy DecentExposure::StrongParametersStrategy
      end

      name = controller.controller_name
      singular = name.singularize
      controller.expose(name, attributes: :resource_attributes)
      controller.expose(singular, attributes: :resource_attributes)
      controller.helper_method :resource
      controller.respond_to :html, :json
    end

    def _prefixes
      super << 'smart_management'
    end

    def resource
      @resource ||= send(singular_model_name)
    end

    def index_builder
      SmartManagement::IndexBuilder.
        new(scope, smart_management_options)
    end

    def json_values
      JsonConverter.new(index_builder, json_options).call
    end
  end
end
