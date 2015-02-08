require 'rails_helper'

module SmartManagement
  describe IndexBuilder do
    describe '#call' do
      context 'when no options are applied' do
        it 'ask for rows in the class requested' do
          items = double(count: 5)
          klass = double('User', all: items)

          actual = IndexBuilder.new(klass, {}).call
          expect(actual[:items]).to eq klass.all
        end

        it 'return the count of all items' do
          items = double(count: 5)
          klass = double('User', all: items)

          actual = IndexBuilder.new(klass, {}).call
          expect(actual[:meta][:total]).to eq 5
        end
      end

      context 'when there is search options' do
        it 'search with search params' do
          items = double(count: 5)
          klass = double('User', all: items)

          search_options = double
          options = { search: search_options }
          searched_items = double(count: 5)
          searcher = double(call: searched_items)

          allow(Searcher).to receive(:new). with(klass.all, search_options)
            .and_return(searcher)

          actual = IndexBuilder.new(klass, options).call

          expect(actual[:items]).to eq searched_items
        end

        it 'return the total of search items' do
          items = double(count: 5)
          klass = double('User', all: items)

          search_options = double
          options = { search: search_options }
          searched_items = double(count: 5)
          searcher = double(call: searched_items)

          allow(Searcher).to receive(:new). with(klass.all, search_options)
            .and_return(searcher)

          actual = IndexBuilder.new(klass, options).call

          expect(actual[:meta][:total]).to eq 5
        end
      end

      context 'when there is pagination options' do
        it 'do the pagination' do
          items = double(count: 5)
          klass = double('User', all: items)

          pagination_options = double
          options = { pagination: pagination_options }
          paginated_items = double('Paginated Users')
          paginer = double(call: paginated_items)

          allow(Paginer).to receive(:new).with(klass.all, pagination_options).
            and_return(paginer)
          allow(paginer).to receive(:call).and_return(paginated_items)

          actual = IndexBuilder.new(klass, options).call

          expect(actual[:items]).to eq paginated_items
        end
      end

      context 'when there is sort options' do
        it 'do the sort' do
          items = double(count: 5)
          klass = double('User', all: items)

          sort_options = double
          options = { sort: sort_options }
          sorted_items = double('Sorted Users')
          sorter = double(call: sorted_items)

          allow(Sorter).to receive(:new).with(klass.all, sort_options).
            and_return(sorter)
          allow(sorter).to receive(:call).and_return(sorted_items)

          actual = IndexBuilder.new(klass, options).call

          expect(actual[:items]).to eq sorted_items
        end
      end
    end
  end
end
