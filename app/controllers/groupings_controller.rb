class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: [:index, :index_chart]

  def index
    @groupings = Grouping.filtered(filters).wat_order.reverse.page(params[:page]).per(params[:per_page] || 20)

    respond_with(@groupings)
  end

  def show
    wat_chart_values = @grouping.chart_data

    @chart = {
      title: {
        text: 'Daily Stats',
      },
      xAxis: {
        type: 'datetime'
      },
      chart: {
        type: 'spline',
        zoomType: 'xy'
      },
      series: [{
                 name: "Wats",
                 data: wat_chart_values
               }]
    }
    respond_with(@grouping)
  end

  def resolve
    @grouping.resolve!
    redirect_to request.referer
  end

  def activate
    @grouping.activate!
    redirect_to request.referer
  end

  def acknowledge
    @grouping.acknowledge!
    redirect_to request.referer
  end

  def load_group
    @grouping = Grouping.find(params.require(:id))
  end

end
