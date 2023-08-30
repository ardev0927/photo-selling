<aside class="main-sidebar">

    <section class="sidebar">

      
        <?= dmstr\widgets\Menu::widget(
            [
                'options' => ['class' => 'sidebar-menu tree',  'data-widget'=> 'tree'],
                'items' => [
                    
                    ['label' => 'Dashboard', 'icon' => 'ion fa-tachometer',  'aria-hidden'=>"true", 'url' => Yii::$app->homeUrl],
                    ['label' => 'Administrators', 'icon' => 'user',  'aria-hidden'=>"true", 'url' => ['/administrator']],
                    ['label' => 'Users', 'icon' => 'users',  'aria-hidden'=>"true", 'url' => ['/user']],
                    ['label' => 'Reported User', 'icon' => 'ion fa-bell',  'aria-hidden'=>"true", 'url' => ['/user/reported-user']],
                    ['label' => 'Post', 'icon' => 'fas fa-bullhorn',  'aria-hidden'=>"true", 'url' => ['/post']],
                    ['label' => 'Reported Post', 'icon' => 'ion fa-bell',  'aria-hidden'=>"true", 'url' => ['/post/reported-post']],
                    ['label' => 'Packages', 'icon' => 'fas fa-money',  'aria-hidden'=>"true", 'url' => ['/package']],
                    ['label' => 'Create Competition', 'icon' => 'fas fa-bullhorn',  'aria-hidden'=>"true", 'url' => ['/competition/create']],
                    ['label' => 'Competition', 'icon' => 'fas fa-bullhorn',  'aria-hidden'=>"true", 'url' => ['/competition']],
                    
                    ['label' => 'Payment Received', 'icon' => 'fas fa-money',  'aria-hidden'=>"true", 'url' => ['/payment']], 
                    ['label' => 'Payment Request', 'icon' => 'fas fa-money',  'aria-hidden'=>"true", 'url' => ['/withdrawal-payment']],
                    ['label' => 'Payout', 'icon' => 'fas fa-money',  'aria-hidden'=>"true", 'url' => ['/withdrawal-payment','type'=>'completed']],
                   
                    
                    
                    ['label' => 'Setting', 'icon' => 'ion fa-wrench',  'aria-hidden'=>"true", 'url' => ['/setting']],

                     
                   /* 
                   ['label' => 'Audio Categories', 'icon' => 'list-alt',  'aria-hidden'=>"true", 'url' => ['/category']],
                    ['label' => 'Audio', 'icon' => 'fas fa-bullhorn',  'aria-hidden'=>"true", 'url' => ['/audio']],
                   ['label' => 'Sub Categories', 'icon' => 'list-alt',  'aria-hidden'=>"true", 'url' => ['/categorysub']],
                    
                    [
                        'label' => 'Membership',
                        'icon' => 'shopping-bag',
                        'url' => '#',
                        'items' => [
                            ['label' => 'Packages', 'icon' => 'fas fa-money', 'url' => ['/package'],],
                            ['label' => 'Promotional Banners', 'icon' => 'fas fa-money', 'url' => ['/promotional-banner'],],
                            
                        ],
                    ],
                    [
                        'label' => 'Ads',
                        'icon' => 'fas fa-bullhorn',
                        'url' => '#',
                        'items' => [
                            
                            ['label' => 'Active Ads', 'icon' => 'fas fa-bullhorn', 'url' => ['/ad','type'=>'active'],],
                            ['label' => 'Pending Ads', 'icon' => 'fas fa-bullhorn', 'url' => ['/ad','type'=>'pending'],],
                            ['label' => 'All Ads', 'icon' => 'fas fa-bullhorn', 'url' => ['/ad','type'=>'all'],],
                            ['label' => 'Expired Ads', 'icon' => 'fas fa-bullhorn', 'url' => ['/ad','type'=>'expire'],],
                            
                            
                        ],
                    ],
                    ['label' => 'Reported Ads', 'icon' => 'ion fa-bell',  'aria-hidden'=>"true", 'url' => ['/ad/reported-ads']],
                    ['label' => 'Banner', 'icon' => 'picture-o',  'aria-hidden'=>"true", 'url' => ['/banner']],
                    ['label' => 'Message', 'icon' => 'fas fa-commenting-o',  'aria-hidden'=>"true", 'url' => ['/message']],
                    ['label' => 'Payment', 'icon' => 'fas fa-money',  'aria-hidden'=>"true", 'url' => ['/payment']],
                    
                    
                    ['label' => 'Setting', 'icon' => 'ion fa-wrench',  'aria-hidden'=>"true", 'url' => ['/setting']],
                    */
                    /*
                    ['label' => 'Gii', 'icon' => 'file-code-o', 'url' => ['/gii']],
                    ['label' => 'Debug', 'icon' => 'dashboard', 'url' => ['/debug']],
                    ['label' => 'Login', 'url' => ['site/login'], 'visible' => Yii::$app->user->isGuest],
                    [
                        'label' => 'Some tools',
                        'icon' => 'share',
                        'url' => '#',
                        'items' => [
                            ['label' => 'Gii', 'icon' => 'file-code-o', 'url' => ['/gii'],],
                            ['label' => 'Debug', 'icon' => 'dashboard', 'url' => ['/debug'],],
                            [
                                'label' => 'Level One',
                                'icon' => 'circle-o',
                                'url' => '#',
                                'items' => [
                                    ['label' => 'Level Two', 'icon' => 'circle-o', 'url' => '#',],
                                    [
                                        'label' => 'Level Two',
                                        'icon' => 'circle-o',
                                        'url' => '#',
                                        'items' => [
                                            ['label' => 'Level Three', 'icon' => 'circle-o', 'url' => '#',],
                                            ['label' => 'Level Three', 'icon' => 'circle-o', 'url' => '#',],
                                        ],
                                    ],
                                ],
                            ],
                        ],
                    ],*/
                ],
            ]
        ) ?>

    </section>

</aside>
