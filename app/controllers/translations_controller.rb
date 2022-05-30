class TranslationsController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @translations = Translation.joins(result_titles).search_by_translation(params[:criteria]).
    select(index_fields).order(order_by).paginate(page: params[:page], :per_page => paginate_lines)
  end

  ### private functions
    private

      ### queries tayloring

      def titles
        Translation.arel_table.alias('titles')
      end

      def results
        Translation.arel_table
      end

      def result_titles
        results.
        join(titles, Arel::Nodes::OuterJoin).
          on(results[:document_id].eq(titles[:document_id]).
          and(results[:document_type].eq(titles[:document_type]).
          and(titles[:language].eq(current_language).and(titles[:field_name].eq('name'))))).
        join_sources
      end

      def index_fields
        [results[:document_id], results[:document_type], results[:language], results[:field_name], results[:translation],
         titles[:translation].as("title")]
      end

      def order_by
        [results[:document_type].asc, results[:translation].asc]
      end
end
