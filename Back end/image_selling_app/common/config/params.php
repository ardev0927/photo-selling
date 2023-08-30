<?php
return [

    'adminEmail' => 'admin@fwdtechnology.co',
    'supportEmail' => 'support@example.com',
    'senderEmail' => 'admin@fwdtechnology.co',
    'senderName' => 'Image Selling',
    
    'user.passwordResetTokenExpire' => 3600,
    
    
    'apiKey.firebaseCloudMessaging'=> '########################', // live
    

    'twilioSid' => '##################', /// 
    'twilioToken' => '####################',
    'smsFromTwilio' => '##########',/// twilo number

    'pathUploadUser' => Yii::getAlias('@frontend') . "/" . 'web/uploads/user/original',
    'pathUploadUserMedium' => Yii::getAlias('@frontend') . "/" . 'web/uploads/user/medium',
    'pathUploadUserThumb' => Yii::getAlias('@frontend') . "/" . 'web/uploads/user/thumb',

    'pathUploadImageFolder' => 'image',
    'pathUploadImage' => Yii::getAlias('@storageUrl') . "/" . 'image',
    
     
    
    'pathUploadUserFolder' => 'user',
    'pathUploadUser' => Yii::getAlias('@storageUrl') . "/" . 'user',

    'pathUploadCompetitionFolder' => 'competition',
    'pathUploadCompetition' => Yii::getAlias('@storageUrl') . "/" . 'competition',

    
   /* 'pathUploadUserThumbFolder' => 'user/thumb',
    'pathUploadThumbUser' => Yii::getAlias('@storageUrl') . "/" . 'user/thumb',
*/
    "postPopularityPoint"=> [
        'postView' => 1,
        'postLike' => 2,
        'postShare' => 3,
        'popuplarPointCondition' =>10

    ],
    
    "apiMessage"=> [
        
        "common"=>[
            "recordFound" =>"Record has been found.",
            "noRecord" =>"No record Found.",
            "actionFailed" =>"Action failed! Please try again.",
            "notAllowed" =>"You are not authorize to do this action.",
        ],
        "user"=>[
            "locationUpdate" =>"User location has been updated successfully.",
            "alreadyReported"=>"You have already reported this user, Your request is under review",
            "reportedSuccess"=>"User reported successfully"
        ],
        "competition"=>[
            "noRecord" =>"No record Found or competition has no longer available.",
            "notAvailable" =>"Competition has no longer available for post image.",
            "joinCompetition" =>"Please join competition before post an image in competition.",
            "alreadyPosted" =>"You have already posted image in competition.",
            "alreadyJoinedCompetition" =>"You have already joined this competition.",
            "joiningFeeNotAvailable" =>"You have not sufficient coin to join this competition.",
            "joinSuccess" =>"You have joined this competition."
            
            
            
            
            
        ],
        
        "post"=>[
            "listFound"=>"Post list found successfully",
            "postCreateSuccess"=>"Post has been created successfully",
            "postCreateFailed"=>"Post has not created successfully",

            "postLikeSuccess"=>"like successfully",
            "postLikeFailed"=>"Remove like successfully",
            "postLikeAlready"=>"You have already liked this post",

            "postUnlikeSuccess"=>"like removed successfully",
            "postUnlikeFailed"=>"Unlike process failed",
            "commentSuccess"=>"Comment added successfully",
            "postShareSuccess"=>"Post shared successfully",
            "alreadyReported"=>"You have already reported this post, Your request is under review",
            "reportedSuccess"=>"Post reported successfully"
            
            
            
        ],
        "payment"=>[
            "amountNotAvailable"=>"Amount is not sufficiant in your wallet to withdrawal",
            "withdrawRequestSuccess"=>"Amount withdrawal request has been genereated successfully",
            "withdrawFailed"=>"Amount withdrawal request failed"
            
        ]
    ],
    "pushNotificationMessage"=> [
        "adApprove"=>[
            "title" =>"Ad Approved",
            "body" =>"Your ad has been approved."
        ],
        "adRejected"=>[
            "title" =>"Ad Rejected",
            "body" =>"Your ad has been rejected."
        ],
        "newOrder"=>[
            "title" =>"New Order",
            "body" =>"New order has been recieved.",
            "type" =>"newOrder"
        ],
        
    ]

    
    


];
