<?php
namespace api\modules\v1\models;
use Yii;
use yii\helpers\ArrayHelper;


class Setting extends \yii\db\ActiveRecord
{

    
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'setting';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [

            [['id'], 'integer'],
            [['email','phone','site_name','facebook','youtube','twitter','linkedin','pinterest','instagram','in_app_purchase_id'], 'string', 'max' => 256],
         
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            
        ];
    }
    public function getEnableDisableDropDownData()
    {
        return array(1 => 'Enable', 0 => 'Disable');
    }
    
    public function getSettingData()
    {
        return $this->find()->orderBy(['id'=>SORT_DESC])->one();
    }
    

}
