class OperationsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @operations = Operation.where(company: @company)
  end

  def new
    @company = Company.find(params[:company_id])
    @operation = Operation.new
  end

  def create
    @operation = Operation.new(operation_params)
    @operation.company = Company.find(params[:company_id])
    @operation.status = "pending"

    if @operation.save!
      redirect_to operation_path(@operation)
    else
      render :new
    end
  end

  def show
    @operation = Operation.find(params[:id])
    @s_document = SDocument.new
    @d_document = DDocument.new

    variables_for_charts
  end

  private

  def operation_params
    params.require(:operation).permit(:name, :category, :target_amount, :expected_closing_date, :premoney)
  end

  def investor_params
    params.require(:operation).permit(:name, :category, :target_amount, :expected_closing_date)
  end

  def variables_for_charts
    # Defines the total amount of the operation (progression chart)
    @shares_values = 0
    @operation.investments.each do |invest|
      @shares_values += (invest.number_of_shares * (@operation.company.share_nominal_value + invest.share_premium))
    end

    # Defines the list of shareholders (dynamic captable with current investments of the operation)
    ## Historic shareholders
    investments = Investment.joins(operation: :company).where('companies.id = ? AND operations.status = ?', @operation.company.id, 'completed')
    @shareholders = {}
    investments.each do |invest|
      if @shareholders.key?(invest.user_id)
        @shareholders[invest.user_id] += invest.number_of_shares
      else
        @shareholders[invest.user_id] = invest.number_of_shares
      end
    end
    ## New shareholders
    if @operation.status != 'completed'
      new_investments = Investment.joins(:operation).where("operations.id = 5 AND (investments.status = 'confirmed' OR investments.status = 'pending')")
      new_investments.each do |invest|
        if @shareholders.key?(invest.user_id)
          @shareholders[invest.user_id] += invest.number_of_shares
        else
          @shareholders[invest.user_id] = invest.number_of_shares
        end
      end
    end
    ## Sort hash by number_of_shares
    @shareholders = @shareholders.transform_keys{ |key| "#{User.find(key).last_name} #{User.find(key).first_name}" }.sort_by { |_k, v| v }.reverse.to_h
  end
end
