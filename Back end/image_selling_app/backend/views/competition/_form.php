<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
use kartik\date\DatePicker;
?>

<div class="countryy-form">

    <?php $form = ActiveForm::begin(); ?>
    
    <?= $form->field($model, 'title')->textInput(['maxlength' => true]) ?>
   
    
    <?php


    echo $form->field($model, 'start_date')->widget(DatePicker::classname(), [
        'options' => ['placeholder' => 'Enter start date ...'],
        //'size' => 'lg',
        'pluginOptions' => [
            'autoclose' => true,
            'format' => 'yyyy-mm-dd',
        ],
    ]);

    echo $form->field($model, 'end_date')->widget(DatePicker::classname(), [
        'options' => ['placeholder' => 'Enter end date ...'],
        'pluginOptions' => [
            'autoclose' => true,
            'format' => 'yyyy-mm-dd',
        ],
    ]); ?>

    <?= $form->field($model, 'award_type')->dropDownList($model->getAwardTypeData()); ?>
    <div id="price_text_block">
        <?= $form->field($model, 'price')->textInput(['maxlength' => true]) ?>
    </div>
    <div id="coin_text_block">
        <?= $form->field($model, 'coin')->textInput(['maxlength' => true]) ?>
    </div>
    <?= $form->field($model, 'joining_fee')->textInput(['maxlength' => true]) ?>
    
    
    <?= $form->field($model, 'status')->dropDownList($model->getStatusDropDownData()); ?>
    
    <?= $form->field($model, 'imageFile')->fileInput() ?>
    <?php if(!$model->isNewRecord && $model->image ){ ?>
    
    <p><?= Html::img($model->imageUrl, ['alt' => 'No Image', 'width' => '50px', 'height' => '50px']);?>
    </p>
    <?php }?>

    <?= $form->field($model, 'exampleFile[]')->fileInput(['multiple' => true]) ?>
    
    <?php if(!$model->isNewRecord ){ ?>
    <div class="panel panel-default">
            <div class="panel-heading">
                <h4>Uploaded Example Images</h4>
            </div>
            <div class="panel-body">
     <?php
     if(count($model->expampleImages)>0){
        foreach($model->expampleImages as $photo){
            ?>
            <div style="width:100px; float:left">
            <?php 
            
            echo Html::img($photo->imageUrl, ['alt' => 'No Image', 'width' => '60px', 'height' => '60px']);   
            echo $form->field($model, 'deletePhoto[]')->checkBox(['label' => 'Delete','data-size'=>'small', 'style'=>'margin-bottom:4px;','value'=>$photo->id]);
            ?>
            </div>
            <?php 


        }
    }else{
        echo 'No Images uploaded';
    }
    
     
     
     ?>   
     
    </div>
    </div>
<?php } ?>   

<?= $form->field($model, 'description')->textArea(['maxlength' => true,'rows'=>6]) ?>
    <div class="form-group">
        <?= Html::submitButton('Save', ['class' => 'btn btn-success']) ?>
    </div>

    <?php ActiveForm::end(); ?>

</div>
<?php
$js=<<< JS
  //  alert('a')
        
  $(document).ready(function(){
    function hideShowDiv() {
        var inputValue = $("#competition-award_type"). val();
        
        if(inputValue==2){
            $('#price_text_block').slideUp();
            $('#coin_text_block').slideDown();
        }else{
            $('#price_text_block').slideDown();
            $('#coin_text_block').slideUp();

            
            
        }
    }
    
    $('#competition-award_type').change(function(){
        hideShowDiv();
       
    });
    hideShowDiv();

});
JS;
$this->registerJs($js,\yii\web\view::POS_READY);
?>