<?php
namespace api\modules\v1\models;
use Yii;
use yii\base\NotSupportedException;
use yii\behaviors\TimestampBehavior;
use yii\db\ActiveRecord;
use yii\web\IdentityInterface;
use api\modules\v1\models\Follower;
use api\modules\v1\models\Post;
use api\modules\v1\models\ReportedUser;


/**
 * User model

 */
class User extends ActiveRecord implements IdentityInterface
{
    const ROLE_ADMIN = 1;
    const ROLE_SUBADMIN=2;
    const ROLE_CUSTOMER=3;
    
    const STATUS_DELETED = 0;
    const STATUS_INACTIVE = 9;
    const STATUS_ACTIVE = 10;
    public $password;
    public $locations;
    public  $imageFile;
    public $social_type;
    public $social_id;
    public $verify_token;
    public $otp;


    /**
	 * @inheritdoc
	 */
	/**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return '{{%user}}';
    }


    /**
     * @inheritdoc
     */
    public static function primaryKey()
    {
        return ['id'];
    }


    public function rules()
    {
        return [
         
            ['status', 'default', 'value' => self::STATUS_INACTIVE],
            ['status', 'in', 'range' => [self::STATUS_ACTIVE, self::STATUS_INACTIVE, self::STATUS_DELETED]],
            [['device_token','description','bio','country_code','phone','dob','country','city','paypal_id'], 'string'],
            [['sex','available_coin'], 'integer'],
            [['email'], 'email'],
            [['available_balance'], 'number'],

            
            [['password'], 'string', 'min' => 6],
            [['name'], 'string', 'min' => 2,'max' => 50],
            [['username'], 'string', 'min' => 2,'max' => 30],
            [['email', 'password','device_type','device_token'], 'required','on'=>'login'],
            [['social_type', 'social_id','name'], 'required','on'=>'loginSocial'],
            [['email'], 'required','on'=>'forgotPassword'],
            [['name','email', 'password','device_type','device_token'], 'required','on'=>'register'],
            [['email'], 'checkUniqueEmail','on'=>'register'],
            [['email'], 'checkUniqueEmail','on'=>['register','profileUpdate']],
            [['name'],'required', 'on'=>'profileUpdate'],
            [['paypal_id'],'required', 'on'=>'profilePaymentDetail'],
            [['phone','country_code'],'required', 'on'=>'updateMobile'],
            [['phone'], 'checkUniquePhone','on'=>'updateMobile'],
            
            [['verify_token','otp'],'required', 'on'=>'verifyMobileOtp'],
            [['otp'], 'checkOtp','on'=>'verifyMobileOtp'],
            //[['username'], 'required','on'=>'searchUser'],
            
            //[['name','locations'],'required', 'on'=>'profileUpdate'],
           // [['imageFile'], 'required', 'on'=>'updateProfileImage'],
            [['imageFile'], 'file', 'skipOnEmpty' => false, 'extensions' => 'png, jpg','on'=>'updateProfileImage'],
           // [['locations'], 'checkUserLocation','on'=>'profileUpdate'],
         /*   [['locations'], 'filter', 'filter' => function ($value) {
                try {
                    $result = [];

                    $data = $value;//\yii\helpers\Json::decode($value);
                    $dynamicModel = (new \yii\base\DynamicModel())->addRule(['country_id', 'country_name'], 'required');
                    foreach ($data as $item) {
                        $itemModel = $dynamicModel->validateData($item);
                        if ($itemModel->hasErrors()) {
                            $this->addError('location', reset($itemModel->getFirstErrors()));
                            return null;
                        }
                    }

                    return $value;
                } catch (\yii\base\InvalidParamException $e) {
                    $this->addError('location', $e->getMessage());
                    return null;
                }
            }],
            */
            


        ];
    }
    public function fields()
    {
        $fields = parent::fields();

        // remove fields that contain sensitive information
       unset($fields['auth_key'],$fields['password_hash'],$fields['password_reset_token']);
       $fields['is_reported'] = (function($model){
         return (@$model->isReported) ? 1: 0;
       });
       $fields[] = 'picture';
     //  $fields[] = 'userLocation';
        return $fields;
    }

    public function extraFields()
    {
        return ['totalPost','totalWinnerPost','follower','following'];
    }

    public function beforeSave($insert)
    {
        if ($insert) {

            $this->created_at = time();
            $this->setPassword($this->password);
            $this->generateAuthKey();
        }else{
            $this->updated_at = time();
        }

        return parent::beforeSave($insert);
    }
    
   
    /**
     * {@inheritdoc}
     */
    public static function findIdentity($id)
    {
        return static::findOne(['id' => $id, 'status' => self::STATUS_ACTIVE]);
    }

    /**
     * {@inheritdoc}
     */
       public static function findIdentityByAccessToken($token, $type = null)
    {
        return static::findOne(['auth_key' => $token]);
    }

    /**
     * Finds user by username
     *
     * @param string $username
     * @return static|null
     */
    public static function findByUsername($username)
    {
        return static::findOne(['username' => $username, 'status' => self::STATUS_ACTIVE]);
    }


    
    public static function findByFb($fbId)
    {
      
        return static::find()->where(['facebook' => $fbId,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }
    public static function findByTwitter($twitterId)
    {
      
        return static::find()->where(['twitter' => $twitterId,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }
    public static function findByApple($appleId)
    {
      
        return static::find()->where(['apple' => $appleId,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }

    public static function findByGoogle($socialId)
    {
      
        return static::find()->where(['googleplus' => $socialId,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }

    
    public static function findByEmail($email)
    {
      
        return static::find()->where(['email' => $email,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }

    public static function findByPhone($phone)
    {
      
        return static::find()->where(['phone' => $phone,'role'=>self::ROLE_CUSTOMER])->andWhere(['<>','status',self::STATUS_DELETED])->one();
    }


    /**
     * Finds user by password reset token
     *
     * @param string $token password reset token
     * @return static|null
     */
    public static function findByPasswordResetToken($token)
    {
        if (!static::isPasswordResetTokenValid($token)) {
            return null;
        }

        return static::findOne([
            'password_reset_token' => $token,
            'status' => self::STATUS_ACTIVE,
        ]);
    }

    /**
     * Finds user by verification email token
     *
     * @param string $token verify email token
     * @return static|null
     */
    public static function findByVerificationToken($token) {
        return static::findOne([
            'verification_token' => $token,
            'status' => self::STATUS_INACTIVE
        ]);
    }

    /**
     * Finds out if password reset token is valid
     *
     * @param string $token password reset token
     * @return bool
     */
    public static function isPasswordResetTokenValid($token)
    {
        if (empty($token)) {
            return false;
        }

        $timestamp = (int) substr($token, strrpos($token, '_') + 1);
        $expire = Yii::$app->params['user.passwordResetTokenExpire'];
        return $timestamp + $expire >= time();
    }

    /**
     * {@inheritdoc}
     */
    public function getId()
    {
        return $this->getPrimaryKey();
    }

    /**
     * {@inheritdoc}
     */
    public function getAuthKey()
    {
        return $this->auth_key;
    }

    /**
     * {@inheritdoc}
     */
    public function validateAuthKey($authKey)
    {
        return $this->getAuthKey() === $authKey;
    }

    /**
     * Validates password
     *
     * @param string $password password to validate
     * @return bool if password provided is valid for current user
     */
    public function validatePassword($password,$password_hash)
    {
        return Yii::$app->security->validatePassword($password, $password_hash);
    }

    /**
     * Generates password hash from password and sets it to the model
     *
     * @param string $password
     */
    public function setPassword($password)
    {
        $this->password_hash = Yii::$app->security->generatePasswordHash($password);
    }

    /**
     * Generates "remember me" authentication key
     */
    public function generateAuthKey()
    {
        $this->auth_key = Yii::$app->security->generateRandomString();
    }

    /**
     * Generates new password reset token
     */
    public function generatePasswordResetToken()
    {
        $this->password_reset_token = Yii::$app->security->generateRandomString() . '_' . time();
    }

    /**
     * Generates new token for email verification
     */
    public function generateEmailVerificationToken()
    {
        $this->verification_token = Yii::$app->security->generateRandomString() . '_' . time();
    }

    /**
     * Removes password reset token
     */
    public function removePasswordResetToken()
    {
        $this->password_reset_token = null;
    }

    public function checkLogin()
    {
      //  print_r($this->email);

      $user = $this->find()->where(['email' => $this->email, 'status' => self::STATUS_ACTIVE])->one();
       if($user){
           if($this->validatePassword($this->password,$user->password_hash)){
            return $user;
           }else{
               return false;
           }
           
       }else{
           return false;
       }
    }

    public function checkLoginSocail($input)
    {
        $modelPackage =  new Package();
      
        $user='';
        if($input['email']){
            
            $user =    $this->findByEmail($input['email']);    
            if($user){
                return $user;
            }
        }
        
        if($input['social_type']=='fb'){
            $user =    $this->findByFb($input['social_id']);    
            if($user){
                return $user;
            }
        }

        if($input['social_type']=='twitter'){
            $user =    $this->findByTwitter($input['social_id']);    
            if($user){
                return $user;
            }
        }

        if($input['social_type']=='apple'){
            $user =    $this->findByApple($input['social_id']);    
            if($user){
                return $user;
            }
        }

        if($input['social_type']=='google'){
            $user =    $this->findByGoogle($input['social_id']);    
            if($user){
                return $user;
            }
        }
       $socialType   =  $input['social_type'];



        $name           = $input['name'];
        $email          = $input['email'];
        $socialId       =  $input['social_id'];
       // $countryId      =  $input['country_id'];
      

        if(!$name){
            $name ='Guest';
        }


        $model = new User();
        $model->name = $name;
        $model->email = $email;
        $model->username = $email;
      //  $model->country_id = $countryId;
        
        if($socialType =='fb'){
            $model->facebook = $socialId;
        }else if($socialType =='twitter'){
            $model->twitter = $socialId;
        }else if($socialType =='apple'){
            $model->apple = $socialId;
        }else if($socialType =='google'){
            $model->googleplus = $socialId;
        }
        $model->role =   User::ROLE_CUSTOMER;
        $model->status = User::STATUS_ACTIVE;
        
        $defaultPackage = $modelPackage->getDefaultPackage();
        if($defaultPackage){
            $model->available_coin =  $defaultPackage->coin;
        }
        

        if($model->save(false)){
            /*$modelSubscription = new Subscription();

            $expiryDate = $modelSubscription->getExpirtyDate($defaultPackage->term);

            $modelSubscription->user_id             =  $model->id;
            $modelSubscription->package_id          =  $defaultPackage->id;
            $modelSubscription->title               =  $defaultPackage->name;
            $modelSubscription->term                =  $defaultPackage->term;
            $modelSubscription->amount              =   $defaultPackage->price;
            $modelSubscription->ad_limit            =  $defaultPackage->ad_limit;
            $modelSubscription->ad_remaining        =   $defaultPackage->ad_limit;
            $modelSubscription->payment_mode        =  Payment::PAYMENT_MODE_PAYPAL;
            $modelSubscription->expiry_date         =  $expiryDate;
            $modelSubscription->save(false);
            */
            return $model;

        }else{

            return false;
        }
      
    }


    public function getPicture()
    {
        if($this->image){
            return Yii::$app->params['pathUploadUser'] ."/".$this->image;
            
        }else{
            return null;
        }
      
    }
    
    /**START valication function custom  */
    public function checkUniqueEmail($attribute, $params, $validator)
    {
        if(!$this->hasErrors()){
            if($this->isNewRecord){
                $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','status',self::STATUS_DELETED])->count();
            }else{
                $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','id',$this->id])->andWhere(['<>','status',self::STATUS_DELETED])->count();
            }
            
            if($count){
                $this->addError($attribute, 'Email already exist');     
            }
            
        }
       
    }

     /**START valication function custom  */
     public function checkUniqueUsername($attribute, $params, $validator)
     {
         if(!$this->hasErrors()){
             if($this->isNewRecord){
                 $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','status',self::STATUS_DELETED])->count();
             }else{
                 $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','id',$this->id])->andWhere(['<>','status',self::STATUS_DELETED])->count();
             }
             
             if($count){
                 $this->addError($attribute, 'Username already exist');     
             }
             
         }
        
     }


    public function checkUniquePhone($attribute, $params, $validator)
    {
        if(!$this->hasErrors()){
            if($this->isNewRecord){
                $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','status',self::STATUS_DELETED])->count();
            }else{
                $count= User::find()->where([$attribute=>$this->$attribute])->andWhere(['<>','id',$this->id])->andWhere(['<>','status',self::STATUS_DELETED])->count();
            }
            
            if($count){
                $this->addError($attribute, 'Phone already exist');     
            }
        }
       
    }

    public function checkOtp($attribute, $params, $validator)
    {
        if(!$this->hasErrors()){
            
            $count= User::find()->where(['verification_token'=>$this->$attribute,'id'=>$this->id])->count();
            
            if($count==0){
                $this->addError($attribute, 'Wrong Otp');     
            }
        }
       
    }

    
    
   

    /**END valication function custom  */

    public function getProfile($id)
    {
      return  $this->find()->select(['id','name','email','bio','description','image','user.is_verified','user.country_code','user.phone','user.country','user.city','user.sex','user.dob','user.paypal_id','user.available_balance','user.available_coin','auth_key'])->where(['id' => $id])->one();
    }
    
    public function getFullProfile($id)
    {
        return $this->find()    
        ->select(['user.id','user.name','user.email','user.bio','user.description','user.image','user.is_verified','user.country_code','user.phone','user.country','user.city','user.sex','user.dob'])
        ->with(['following.followingUserDetail'=> function ($query) {
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
        }])
        ->with(['follower.followerUserDetail'=> function ($query) {
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
        }])
        ->where(['user.id' => $id,'user.role'=>User::ROLE_CUSTOMER])->one();
    }
    public function getFullProfileMy($id)
    {
        return $this->find()    
        ->select(['user.id','user.name','user.email','user.bio','user.description','user.image','user.is_verified','user.country_code','user.phone','user.country','user.city','user.sex','user.dob','user.paypal_id','user.available_balance','user.available_coin'])
        ->with(['following.followingUserDetail'=> function ($query) {
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
        }])
        ->with(['follower.followerUserDetail'=> function ($query) {
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
        }])
        ->where(['user.id' => $id,'user.role'=>User::ROLE_CUSTOMER])->one();
    }

   
    public function getPackage()
    {
        return $this->hasMany(Package::className(), ['id'=>'package_id']);
    }
    public function getFollowing()
    {
        return $this->hasMany(Follower::className(), ['follower_id'=>'id']);
        //->joinWith('follwingUser');
        
    }
    public function getFollower()
    {
        return $this->hasMany(Follower::className(), ['user_id'=>'id']);
    }

    public function getActiveSubscripton()
    {
        //getFullProfile
        return $this->hasOne(Subscription::className(), ['user_id'=>'id'])->where(['subscription.status' => Subscription::STATUS_ACTIVE])->andWhere(['>','subscription.expiry_date',time()]);
    }

    public function getTotalPost()
    {
        return $this->hasMany(Post::className(), ['user_id'=>'id'])->count();
    }

    public function getTotalWinnerPost()
    {
        
        return $this->hasMany(Post::className(), ['user_id'=>'id'])->where(['post.is_winning' => Post::IS_WINNING_YES])->count();
    }

     
    public function getisReported()
    {
        return $this->hasOne(ReportedUser::className(), ['report_to_user_id'=>'id'])->andOnCondition(['reported_user.user_id' => Yii::$app->user->identity->id]);
    }
  

    

    
   
    






}
