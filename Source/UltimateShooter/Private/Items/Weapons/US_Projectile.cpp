// Fill out your copyright notice in the Description page of Project Settings.


#include "Items/Weapons/US_Projectile.h"

// Sets default values
AUS_Projectile::AUS_Projectile()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void AUS_Projectile::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void AUS_Projectile::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

