<?php
namespace common\models;
use Yii;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "countryy".
 *
 */
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
           // [['name', 'status'], 'save'],

        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
           
            'site_name' => Yii::t('app', 'Site Name'),
            
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
