###################################
#
# EVM Automate Method: VmReconfigureRequest_Approved
#
# Notes: This method is used to email the requester that
# VM reconfiguration request has been approved
#
# Events: request_approved
#
# Model Notes:
# 1. to_email_address - used to specify an email address in the case where the
#    requester does not have a valid email address. To specify more than one email
#    address separate email address with commas. (I.e. admin@company.com,user@company.com)
# 2. from_email_address - used to specify an email address in the event the
#    requester replies to the email
# 3. signature - used to stamp the email with a custom signature
#
###################################
begin
  @method = 'VmReconfigureRequest_Approved'
  $evm.log("info", "#{@method} - EVM Automate Method Started")

  # Turn of verbose logging
  @debug = true


  ###################################
  #
  # Method: emailrequester
  #
  # Send email to requester
  #
  ###################################
  def emailrequester(miq_request, appliance)
    $evm.log('info', "#{@method} - Requester email logic starting") if @debug

    # Get requester object
    requester = miq_request.requester

    # Get requester email else set to nil
    requester_email = requester.email || nil

    # Get Owner Email else set to nil
    owner_email = miq_request.options[:owner_email] || nil
    $evm.log('info', "#{@method} - Requester email:<#{requester_email}> Owner Email:<#{owner_email}>") if @debug

    # if to is nil then use requester_email
    to = nil
    to ||= requester_email

    # If to is still nil use to_email_address from model
    to ||= $evm.object['to_email_address']

    # Get from_email_address from model unless specified below
    from = nil
    from ||= $evm.object['from_email_address']

    # Get signature from model unless specified below
    signature = nil
    signature ||= $evm.object['signature']

    # Build subject
    subject = "Request ID #{miq_request.id} - Your Virtual Machine configuration was Approved"

    # Build email body
    body = "Hello, "
    body += "<br>Your Virtual Machine ReConfiguration Request was approved. You will be notified via email when the VM has completed its ReConfiguration."
    body += "<br><br>Approvers notes: #{miq_request.reason}"
    body += "<br><br>To view this Request go to: <a href='https://#{appliance}/miq_request/show/#{miq_request.id}'>https://#{appliance}/miq_request/show/#{miq_request.id}</a>"
    body += "<br><br> Thank you,"
    body += "<br> #{signature}"

    # Send email
    $evm.log("info", "#{@method} - Sending email to <#{to}> from <#{from}> subject: <#{subject}>") if @debug
    $evm.execute(:send_email, to, from, subject, body)
  end

  # Get miq_request from root
  miq_request = $evm.root['miq_request']
  raise "miq_request missing" if miq_request.nil?
  $evm.log("info", "#{@method} - Detected Request:<#{miq_request.id}> with Approval State:<#{miq_request.approval_state}>") if @debug

  # Override the default appliance IP Address below
  appliance = nil
  #appliance ||= 'evmserver.company.com'
  appliance ||= $evm.root['miq_server'].ipaddress


  # Email Requester
  emailrequester(miq_request, appliance)

  #
  # Exit method
  #
  $evm.log("info", "#{@method} - EVM Automate Method Ended")
  exit MIQ_OK

  #
  # Set Ruby rescue behavior
  #
rescue => err
  $evm.log("error", "#{@method} - [#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end
