*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.  

Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library    RPA.Desktop
Library    RPA.Tables
Library    RPA.Archive
Library    OperatingSystem
Library    RPA.FTP

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    class:alert-buttons

Get orders
    Download     https://robotsparebinindustries.com/orders.csv
    ${orders}=    Read table from CSV  orders.csv    header=True
    [Return]    ${orders}


Close the annoying modal
    Click Button    Yep

Fill the form
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    Click Button    id-body-${row}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    Preview

Submit the order
    Wait Until Keyword Succeeds    4x    0.5s    Submit

Submit
    Click Button    order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${Order Number}
    ${receipt_html}=    Get Element Attribute    id:receipt   outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}robot-receipt${Order Number}.pdf
    [Return]    ${OUTPUT_DIR}${/}robot-receipt${Order Number}.pdf

Take a screenshot of the robot
    [Arguments]    ${Order Number}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}robot-preview${Order Number}.png
    [Return]    ${OUTPUT_DIR}${/}robot-preview${Order Number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${files}=    Create List
    ...    ${pdf}
    ...    ${screenshot}
    Add Files To Pdf    ${files}    ${pdf}
    Delete   ${screenshot}

Go to order another robot
    Click Button    order-another
    Wait Until Element Is Visible    head

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}
    ...    ${zip_file_name}