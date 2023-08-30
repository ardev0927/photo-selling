<?php
namespace api\modules\v1\controllers;
use Yii;
use yii\rest\ActiveController;
use yii\filters\auth\CompositeAuth;
use yii\filters\auth\HttpBearerAuth;
use yii\helpers\ArrayHelper;
use yii\data\ActiveDataProvider;
use api\modules\v1\models\Payment;
use api\modules\v1\models\WithdrawalPayment;
use api\modules\v1\models\WithdrawalPaymentSearch;
use api\modules\v1\models\PaymentSearch;
use api\modules\v1\models\Package;
use api\modules\v1\models\User;


class PaymentController extends ActiveController
{
    public $modelClass = 'api\modules\v1\models\payment';   





    
    public function actions()
	{
		$actions = parent::actions();

		// disable default actions
		unset($actions['create'], $actions['update'], $actions['index'], $actions['delete'], $actions['view']);                    

		return $actions;
    }    
    
   

    public function behaviors()
    {
        $behaviors = parent::behaviors();
        $behaviors['authenticator'] = [
            'class' => CompositeAuth::className(),
            'except'=>[],
            'authMethods' => [
                HttpBearerAuth::className()
            ],
        ];
        return $behaviors;
    }

    
    public function actionPackageSubscription()
    {
       
        $model          = new Payment();
        $modelPackage   = new Package();
      

        $userId = Yii::$app->user->identity->id;
        $model->scenario ='packageSubscription';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
        
            return $response;
        }
        $packageId =  @(int) $model->package_id;
        $packageResult =$modelPackage->findOne($packageId);


        $modelUser =  User::findOne($userId);
        $modelUser->available_coin =  $modelUser->available_coin + $packageResult->coin;

                
        if($modelUser->save(false)){



            $model->type                 =  Payment::TYPE_COIN;
            $model->transaction_type     =  Payment::TRANSACTION_TYPE_CREDIT;
            $model->payment_type         =  Payment::PAYMENT_TYPE_PACKAGE;
            $model->payment_mode         =  Payment::PAYMENT_MODE_IN_APP_PURCHASE;
            $model->coin                 =  $packageResult->coin;
            
            $amount = $model->amount;
            unset($model->amount);
            

            if($model->save(false)){

                $modelPaymentLog          = new Payment();

                $modelPaymentLog->type                 =  Payment::TYPE_PRICE;
                $modelPaymentLog->user_id               =  $model->user_id;
                $modelPaymentLog->package_id            =  $model->package_id;
                
                $modelPaymentLog->transaction_type     =  Payment::TRANSACTION_TYPE_CREDIT;
                
                $modelPaymentLog->payment_type         =  Payment::PAYMENT_TYPE_PACKAGE;
                $modelPaymentLog->payment_mode         =  Payment::PAYMENT_MODE_IN_APP_PURCHASE;
                $modelPaymentLog->transaction_id            =  $model->transaction_id;
                $modelPaymentLog->amount               =  $amount;
                $modelPaymentLog->save(false);

                $response['message']='Package subscribed successfully';
                return $response; 
            }
        }else{
            $response['statusCode']=422;
            $response['message']='Package not subscribed successfully';
            return $response; 

        }
    }


     /**payment my history */

     public function actionPaymentHistory()
     {
        
         $userId = Yii::$app->user->identity->id;
         $modelUser = new User();
         
         $model = new \yii\base\DynamicModel([
             'month', 'string'
              ]);
         $model->addRule(['month'], 'required');
         $model->load(Yii::$app->request->queryParams, '');
         $model->validate();
         if ($model->hasErrors()) {
                 $response['statusCode']=422;
                 $response['errors']=$model->errors;
                 return $response;
             
         }
         
         $modelSearch                           = new PaymentSearch();
         $result = $modelSearch->searchMyPayment(Yii::$app->request->queryParams);
 
         $resultUser = $modelUser->find()->select(['available_balance','available_coin'])->where(['id'=>$userId])->one();
 
         
         $response['message']=  Yii::$app->params['apiMessage']['common']['recordFound'];
         $response['available_balance']=  $resultUser->available_balance;
         $response['available_coin']=  $resultUser->available_coin;
         $response['payment']=  $result;
         
         return $response; 
     }



     /**payment withdrawal request hostory */

     public function actionWithdrawalHistory()
     {

//        $userId = Yii::$app->user->identity->id;
        $modelSearch                           = new WithdrawalPaymentSearch();
        $result = $modelSearch->searchMyWithdrawalPayment(Yii::$app->request->queryParams);
        $response['message']=  Yii::$app->params['apiMessage']['common']['recordFound'];
        
         $response['payment']=  $result;
        return $response; 
    }
 

       /**payment withdrawal request */

       public function actionWithdrawal()
       {
  
            $userId = Yii::$app->user->identity->id;
            $modelUser = new User();
            $resultUer = $modelUser->findOne($userId);
            $resultUer->available_balance; 
            if($resultUer->available_balance <=0){
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['payment']['amountNotAvailable'];
                $response['errors']=$errors;
                return $response;
            }
            $withdrawalAmount = $resultUer->available_balance;
            $resultUer->available_balance =  0;//$resultUer->available_balance - $model->amount;
            if($resultUer->save(false)){
                $modelWithdrawPayment                       =  new WithdrawalPayment();
                $modelWithdrawPayment->user_id              =  $userId;
                $modelWithdrawPayment->amount               =  $withdrawalAmount;
                $modelWithdrawPayment->save(false);


                $modelPayment                   = new Payment();
                $modelPayment->user_id          =  $userId;
                $modelPayment->type             =  Payment::TYPE_PRICE;
                $modelPayment->amount           =  $withdrawalAmount;
                
                $modelPayment->transaction_type =  Payment::TRANSACTION_TYPE_DEBIT;
                $modelPayment->payment_type     =  Payment::PAYMENT_TYPE_WITHDRAWAL;
                $modelPayment->payment_mode     =  Payment::PAYMENT_MODE_WALLET;
                $modelPayment->save(false);
               


                $response['message']=  Yii::$app->params['apiMessage']['payment']['withdrawRequestSuccess'];
                
            }else{
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['payment']['withdrawFailed'];
                $response['errors']=$errors;
            }
    
    
        return $response; 
    }
   


}