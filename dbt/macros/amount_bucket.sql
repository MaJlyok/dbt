{% macro amount_bucket(amount_column) %}
    case
        when {{ amount_column }} < 10 then 'xs'
        when {{ amount_column }} < 50 then 's'
        when {{ amount_column }} < 200 then 'm'
        when {{ amount_column }} < 500 then 'l'
        else 'xl'
    end
{% endmacro %}
