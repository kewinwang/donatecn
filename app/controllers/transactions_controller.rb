# coding: utf-8
class TransactionsController < ApplicationController
  def notify
    notification = ActiveMerchant::Billing::Integrations::Alipay::Notification.new(request.raw_post)

    transaction_attributes = {
      :total_fee    => notification.total_fee,
      :trade_status => notification.trade_status,
      :trade_no     => notification.trade_no,
      :notify_time  => notification.notify_time,
      :buyer_email  => notification.buyer_email,
      :raw_post     => request.raw_post
    }

    if transaction = Transaction.find_by_notify_id(notification.notify_id)
      result = transaction.update_attributes(transaction_attributes)
    else
      transaction_attributes.merge!(:notify_id => notification.notify_id)
      result = Transaction.create(transaction_attributes)
    end

    if result
      render :text => "success"
    else
      render :text => "failure"
    end
  end

  def done
    r = ActiveMerchant::Billing::Integrations::Alipay::Return.new(request.query_string)
    if r.success?
      flash[:notice] = '捐助成功！'
    else
      flash[:error] = '捐助失败！'
    end
    redirect_to root_path
  end
end
