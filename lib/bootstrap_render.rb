module WillPaginate
  module ViewHelpers
 
    # WillPaginate link renderer for Twitter Bootstrap
    class BoostrapLinkRenderer < WillPaginate::Sinatra::LinkRenderer
      protected
 
      def page_number(page)
        unless page == current_page
          tag(:li, link(page, page, :rel => rel_value(page)))
        else
          tag(:li, link(page, '#'), :class => 'active')
        end
      end
 
      def next_page
        num = @collection.current_page < total_pages && @collection.current_page + 1
        previous_or_next_page(num, '下一页', 'next')
      end
 
      def previous_page
        num = @collection.current_page > 1 && @collection.current_page - 1
        # previous_or_next_page(num, @options[:previous_label], 'previous')
        previous_or_next_page(num, '上一页', 'previous')
      end
 
      def previous_or_next_page(page, text, classname)
        if page
          tag(:li, link(text, page), :class => classname)
        else
          tag(:li, link(text, '#'), :class => classname + ' disabled')
        end
      end
 
      def html_container(html)
        tag(:ul, html, container_attributes)
      end
 
    end
  end
end