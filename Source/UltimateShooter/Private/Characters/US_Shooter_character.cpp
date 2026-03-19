// Fill out your copyright notice in the Description page of Project Settings.


#include "Characters/US_Shooter_character.h"

// Sets default values
AUS_Shooter_character::AUS_Shooter_character()
{
 	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void AUS_Shooter_character::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void AUS_Shooter_character::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

// Called to bind functionality to input
void AUS_Shooter_character::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

}

