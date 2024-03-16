clc
clear all
close all

% Initial Parameter for stations
a = [-90,0];
b = [0,0];
c = [90,0];


% Initializing EV3 object
myev3 = legoev3('usb');

home_posi(myev3); % Calling home psoition function

mysonicsensor = sonicSensor(myev3,2);

%Get all the initial heights
disp("Initial heights of stations")
disp(" ")
initial_height(a(1), myev3);
a(2) = readDistance(mysonicsensor);

home_posi(myev3);
b(2) = readDistance(mysonicsensor);

initial_height(c(1), myev3);
c(2) = readDistance(mysonicsensor);

home_posi(myev3); % home position

disp("The height at station A = ")
disp(a(2))
disp("The height at station B = ")
disp(b(2))
disp("The height at station C = ")
disp(c(2))

pause(2)
station_B(1, b(1), b(2), myev3); %pick from B
station_C(2, c(1), c(2), myev3); %place at C
home_posi(myev3); % Calling home psoition function

station_C(1, c(1), c(2), myev3); %pick from C
station_A(3, a(1), a(2), myev3); %place at A
home_posi(myev3); % Calling home psoition function

station_A(1, a(1), a(2), myev3); %pick from A
station_B(4, b(1), b(2), myev3); %place at B
home_posi(myev3); % Calling home psoition function

station_B(1, b(1), b(2), myev3); %pick from B
station_A(5, a(1), a(2), myev3); %place at A
home_posi(myev3); % Calling home psoition function

station_A(1, a(1), a(2), myev3); %pick from A
station_C(6, c(1), c(2), myev3); %place at C
home_posi(myev3); % Calling home psoition function

station_C(1, c(1), c(2), myev3); %pick from C
station_B(7, b(1), b(2), myev3); %place at B
home_posi(myev3); % Calling home psoition function

function[] = home_posi(myev3)
    % Declaration of motors and sensors
    motorA = motor(myev3,'A');
    motorB = motor(myev3,'B');
    motorC = motor(myev3,'C');
    touchsensor_1 = touchSensor(myev3,1);
    touchsensor_3 = touchSensor(myev3,3);
    pressed_1 = readTouch(touchsensor_1);
    pressed_3 = readTouch(touchsensor_3);

    rotationC = readRotation(motorC);

    while(pressed_1 ~= 1)
        start(motorC)
        motorC.Speed = 30;
        pressed_1 = readTouch(touchsensor_1);
    end
    motorC.Speed = 0;
    resetRotation(motorC);

    while(pressed_3 ~= 1)
        start(motorB)
        motorB.Speed = -25;
        pressed_3 = readTouch(touchsensor_3);
    end
    motorB.Speed = 0;
    resetRotation(motorB)

    rotate_base = 3*90;
    if(rotate_base >= (-readRotation(motorC)))
        while(rotate_base >= (-readRotation(motorC)))
            start(motorC)
            readRotation(motorC);
            motorC.Speed = -20;
        end
        motorC.Speed = 0;
        resetRotation(motorC);
    end
    pause(2);
    resetRotation(motorC)
    resetRotation(motorB)
    motorA.Speed = 5;
    pause(0.4);
    motorA.Speed = 0;

end

function[] = initial_height(theta,myev3) 
    % Declaration of motors and sensors
    motorC = motor(myev3,'C');
    rotationC = readRotation(motorC);

    rotate_base_1 = 3*theta;
    if(rotate_base_1 >= (-readRotation(motorC)))
        while(rotate_base_1 >= (-readRotation(motorC)))
            start(motorC)
            readRotation(motorC);
            motorC.Speed = -20;
        end
    elseif(rotate_base_1 < (-readRotation(motorC)))
        while(rotate_base_1 < (-readRotation(motorC)))
            start(motorC)
            readRotation(motorC);
            motorC.Speed = 20;
        end   
    end

    resetRotation(motorC)
    motorC.Speed = 0;
    pause(2)

end

function[] = position(theta,myev3) 
    % Declaration of motors and sensors
    motorC = motor(myev3,'C');
    
    rotationC = readRotation(motorC);

    rotate_base_1 = 3*theta;
    tot_error = 0;
    if(rotate_base_1 >= (-readRotation(motorC)))
        while(rotate_base_1 >= (-readRotation(motorC)))
            start(motorC)
            readRotation(motorC);
            error_1 = rotate_base_1 - (- readRotation(motorC));
            motorC.Speed = -PIController(error_1,tot_error);
        end
    elseif(rotate_base_1 < (-readRotation(motorC)))
        while(rotate_base_1 < (-readRotation(motorC)))
            start(motorC)
            readRotation(motorC);
            error_2 = rotate_base_1 + (- readRotation(motorC));
            motorC.Speed = PIController(error_2,tot_error);
        end   
    end

    resetRotation(motorC)
    motorC.Speed = 0;
    pause(2)

end

% function for station A
function[] = station_A(p, a_1, a_2, myev3) 
    disp('Now picking ball from B station')
    theta_1 = a_1;
    theta_2 = ang_B(a_2);
    
    if (p == 1) % picking if p equal to 1
        position(theta_1,myev3); % calling position function
        disp('Now picking ball from A station')
        pick(theta_2,myev3);
    
    elseif (p == 3) % placing 
        position(-180,myev3); % calling position function
        disp('Now placing ball in A station')
        place(theta_2,myev3);

    elseif (p == 5) % placing 
        position(-90,myev3); % calling position function
        disp('Now placing ball in A station')
        place(theta_2,myev3);
    end

end

% function for station B
function[] = station_B(p, b_1, b_2, myev3)
    
    theta_1 = b_1;
    theta_2 = ang_B(b_2);

    if (p == 1) % picking if p equal to 1
        position(theta_1,myev3); % calling position function
        disp('Now picking ball from B station')
        pick(theta_2,myev3);
    
    elseif (p == 4) % placing 
        position(90,myev3); % calling position function
        disp('Now placing ball in B station')
        place(theta_2,myev3);

    elseif (p == 7) % placing 
        position(-90,myev3); % calling position function
        disp('Now placing ball in B station')
        place(theta_2,myev3);
    end
end

% function for station C
function[] = station_C(p, c_1, c_2, myev3)
    disp('Now picking ball from B station')
    theta_1 = c_1;
    theta_2 = ang_B(c_2);
    
    if (p == 1) % picking if p equal to 1
        position(theta_1,myev3); % calling position function
        disp('Now picking ball from C station')
        pick(theta_2,myev3);
    
    elseif (p == 2) % placing 
        position(90,myev3); % calling position function
        disp('Now placing ball in C station')
        place(theta_2,myev3);

    elseif (p == 6) % placing 
        position(180,myev3); % calling position function
        disp('Now placing ball in C station')
        place(theta_2,myev3);
    end
end

function[] = pick(theta_2,myev3) % Pick function
    % Declaration of motors and sensors
    motorA = motor(myev3,'A');
    motorB = motor(myev3,'B');
    motorC = motor(myev3,'C');
    touchsensor_3 = touchSensor(myev3,3);
    pressed_3 = readTouch(touchsensor_3);

    rotationB = readRotation(motorB);
    rotationC = readRotation(motorC);
    
    start(motorA)
    resetRotation(motorC)

    arm_angle = theta_2;
    motorA.Speed = -5; % opening
    pause(0.5);
    motorA.Speed = 0;
    tot_error = 0;
    while(arm_angle > readRotation(motorB))
        readRotation(motorB)
        error = arm_angle - readRotation(motorB);
        start(motorB)
        motorB.Speed = PIController(error,tot_error);
    end
    motorB.Speed = 0;
    
    start(motorA)
    motorA.Speed = 10; % closing
    pause(0.4);
    motorA.Speed = 0;
    pressed_3 = readTouch(touchsensor_3);
    while(pressed_3 ~= 1)
        start(motorB)
        motorB.Speed = -25;
        pressed_3 = readTouch(touchsensor_3);
    end
    motorB.Speed = 0;
    resetRotation(motorB)
    
end

function[] = place(theta_2,myev3) % Placing function
    % Declaration of motors and sensors
    motorA = motor(myev3,'A');
    motorB = motor(myev3,'B');
    motorC = motor(myev3,'C');
    touchsensor_3 = touchSensor(myev3,3);
    pressed_3 = readTouch(touchsensor_3);
    rotationB = readRotation(motorB);
    rotationC = readRotation(motorC);

    start(motorA)
    resetRotation(motorC)
    tot_error = 0;
    place_angle = theta_2;
    while(place_angle > readRotation(motorB))
        readRotation(motorB)
        error = place_angle - readRotation(motorB);
        start(motorB)
        motorB.Speed = PIController(error,tot_error);
    end
    motorB.Speed = 0;

    start(motorA)
    motorA.Speed = -7; % opening
    pause(0.4);
    motorA.Speed = 0;
    pressed_3 = readTouch(touchsensor_3);
    while(pressed_3 ~= 1)
        start(motorB)
        motorB.Speed = -20;
        pressed_3 = readTouch(touchsensor_3);
    end
    motorB.Speed = 0;
    resetRotation(motorB)

    motorA.Speed = 10; % Closing
    pause(0.4);
    motorA.Speed = 0;

end

function speed = PIController(error,tot_error)
      Kp = 0.05;
      ki = 10;
      i=0;
    while (i==0)
        tic;
        toc;
        t= toc;
        i=1;
    end
       	
      tot_error = tot_error + error;
      d = error * Kp + ki*tot_error*t;
      if  d<20
          speed = 20;
      elseif  d<-20 
          speed = -20;
      else 
          speed = d;
      end
end

% Angle Calculation for different stations using inverse kinematics
function theta_2 = ang_B(Z) 
    O_ffset = 55;
    l0 = 70;
    l1 = 50;
    l2 = 95;
    l3 = 185;
    l4 = 110;
    
    theta_2 = (asind((l4 - O_ffset + Z*1000 - l2*sind(45) - l1 - l0)/l3) + 45) * 5 ;

end
 

